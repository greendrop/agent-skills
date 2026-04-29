# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

AI エージェント向けスキル（プロンプト）を管理・配布するリポジトリ。各スキルは `<skill-name>/SKILL.md` として管理され、`gh skill publish` を通じて配布される。

## コマンド

ツール管理には [mise](https://mise.jdx.dev/) を使用する。

```bash
# すべての SKILL.md を検証する
mise run skills:validate

# 特定の SKILL.md を検証する
mise run skills:validate:one commit/SKILL.md

# YAML ファイルを lint する
yamllint .

# GitHub Actions ワークフローを lint する
actionlint -color
ghalint run
```

## SKILL.md の構造

各スキルは `<skill-name>/SKILL.md` に配置する。先頭に YAML frontmatter が必須。

```markdown
---
name: <skill-name> # 親ディレクトリ名と一致させること
description: スキルの説明
version: "YYYY.MM.DD.N" # CalVer 形式 (例: 2026.04.29.1)
source: "github.com/greendrop/agent-skills"
---

スキルの本文（プロンプト）
```

**バリデーションルール（`scripts/validate-skills.sh`）:**

- `name` は親ディレクトリ名と一致すること
- `version` は `YYYY.MM.DD.N` 形式（例: `2026.04.29.1`）
- `source` は `github.com/greendrop/agent-skills` 固定
- `.claude/`, `.copilot/`, `.agents/` 配下の SKILL.md はバリデーション対象外

## CI/CD ワークフロー

| ワークフロー          | トリガー                           | 処理                                       |
| --------------------- | ---------------------------------- | ------------------------------------------ |
| `skill-validate`      | PR（SKILL.md 変更時）              | バリデーション + バージョン更新チェック    |
| `skill-publish`       | main へのマージ（SKILL.md 変更時） | CalVer タグを採番して `gh skill publish`   |
| `skill-update`        | 毎週月曜 / 手動                    | `gh skill update --all` を実行し PR を作成 |
| `yamllint`            | PR（YAML ファイル変更時）          | YAML lint                                  |
| `github-actions-lint` | PR（ワークフロー変更時）           | actionlint + ghalint                       |

## スキルの追加・更新手順

1. `<skill-name>/SKILL.md` を作成または編集する
2. frontmatter の `version` を更新する（PR で変更する場合は必須）
3. `mise run skills:validate` でローカル検証
4. PR を作成 → main にマージされると自動でパブリッシュされる

## インストール済みスキルの管理

`<ai-agent-tool-dir>/skills/<skill-name>/SKILL.md` にインストール済みスキルが格納される。このファイルには `metadata` フィールド（`github-path`, `github-ref`, `github-repo`, `github-tree-sha`）が追加されており、`gh skill update --all` で自動更新される。手動編集は不要。
