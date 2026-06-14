#!/usr/bin/env bash
set -euo pipefail

EXPECTED_SOURCE="github.com/greendrop/agent-skills"
VERSION_PATTERN='^[0-9]{4}\.(0[1-9]|1[0-2])\.(0[1-9]|[12][0-9]|3[01])\.[1-9][0-9]*$'

if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  RESET='\033[0m'
else
  RED=''
  GREEN=''
  RESET=''
fi

extract_frontmatter() {
  awk 'NR==1 && /^---$/{f=1; next} f && /^---$/{exit} f{print}' "$1"
}

validate_file() {
  local file="$1"
  local errors=()

  local frontmatter
  frontmatter=$(extract_frontmatter "$file")

  if [[ -z "$frontmatter" ]]; then
    errors+=("frontmatter: not found (missing --- block)")
    printf "${RED}[FAIL]${RESET} %s\n" "$file"
    for err in "${errors[@]}"; do
      printf "  - %s\n" "$err"
    done
    return 1
  fi

  local name description version source
  name=$(printf '%s' "$frontmatter" | yq '.name // ""')
  description=$(printf '%s' "$frontmatter" | yq '.description // ""')
  version=$(printf '%s' "$frontmatter" | yq '.version // ""')
  source=$(printf '%s' "$frontmatter" | yq '.source // ""')

  local dir_name
  dir_name=$(basename "$(dirname "$file")")

  if [[ -z "$name" || "$name" == "null" ]]; then
    errors+=("name: required field is missing or empty")
  elif [[ "$name" != "$dir_name" ]]; then
    errors+=("name: expected '$dir_name' (parent directory name), got '$name'")
  else
    local name_len=${#name}
    if [[ $name_len -gt 64 ]]; then
      errors+=("name: max 64 characters allowed, got $name_len")
    fi
  fi

  if [[ -z "$description" || "$description" == "null" ]]; then
    errors+=("description: required field is missing or empty")
  else
    local desc_len=${#description}
    if [[ $desc_len -gt 1024 ]]; then
      errors+=("description: max 1024 characters allowed, got $desc_len")
    fi
  fi

  if [[ -z "$version" || "$version" == "null" ]]; then
    errors+=("version: required field is missing or empty")
  elif ! printf '%s' "$version" | grep -qE "$VERSION_PATTERN"; then
    errors+=("version: expected YYYY.MM.DD.N format (e.g. 2026.04.29.1), got '$version'")
  fi

  if [[ -z "$source" || "$source" == "null" ]]; then
    errors+=("source: required field is missing or empty")
  elif [[ "$source" != "$EXPECTED_SOURCE" ]]; then
    errors+=("source: expected '$EXPECTED_SOURCE', got '$source'")
  fi

  if [[ ${#errors[@]} -gt 0 ]]; then
    printf "${RED}[FAIL]${RESET} %s\n" "$file"
    for err in "${errors[@]}"; do
      printf "  - %s\n" "$err"
    done
    return 1
  else
    printf "${GREEN}[PASS]${RESET} %s\n" "$file"
    return 0
  fi
}

find_skill_files() {
  find . -name "SKILL.md" \
    -not -path "./.claude/*" \
    -not -path "./.copilot/*" \
    -not -path "./.agents/*" \
    | sort
}

main() {
  local files=()

  if [[ $# -gt 0 ]]; then
    files=("$@")
  else
    while IFS= read -r file; do
      files+=("$file")
    done < <(find_skill_files)
  fi

  if [[ ${#files[@]} -eq 0 ]]; then
    printf "No SKILL.md files found.\n"
    exit 0
  fi

  local passed=0
  local failed=0

  for file in "${files[@]}"; do
    if validate_file "$file"; then
      ((passed++)) || true
    else
      ((failed++)) || true
    fi
  done

  local total=$(( passed + failed ))
  printf "\n---\n%d files checked, %d passed, %d failed\n" "$total" "$passed" "$failed"

  [[ $failed -eq 0 ]]
}

main "$@"
