---
description: 現在のブランチの変更を確認し、GitHub Pull Request を作成する
metadata:
    github-path: greendrop-github-create-pr
    github-ref: refs/tags/v2026.05.15.1
    github-repo: https://github.com/greendrop/agent-skills
    github-tree-sha: 92087e61404fd6a172ac85d4f64e1c300280e813
name: greendrop-github-create-pr
source: github.com/greendrop/agent-skills
version: 2026.05.15.1
---
`general-purpose` サブエージェントを起動し、以下の「サブエージェントへのプロンプト」セクションの内容をそのままプロンプトとして渡して実行させてください。サブエージェントの実行結果をユーザーに表示してください。

---

## サブエージェントへのプロンプト

現在のブランチの変更を確認して GitHub Pull Request を作成してください。

### 手順

1. **現在の状態を確認する**（並列実行）
   - `git branch --show-current` — 現在のブランチ名
   - `git log main...HEAD --oneline` — main からの差分コミット一覧
   - `git diff main...HEAD` — main からの差分

   ブランチ名が `main` または `develop` であれば、PR は作成せずその旨を伝えて中断する。

2. **PR テンプレートを読み込む**

   `.github/pull_request_template.md` が存在する場合は内容を読み込み、そのセクション構成を本文の雛形として使う。存在しない場合は以下のデフォルト構成を使う:

   ```
   ## 概要

   ## 変更内容
   ```

3. **変更内容を分析して PR の内容を作成する**

   コミット一覧と差分を元に、テンプレートの各セクションを埋める:

   - **タイトル**: 変更全体を一言で表す（日本語・70文字以内）
   - テンプレートの HTML コメント（`<!-- ... -->`）はヒントとして参考にし、本文には含めない

4. **PR を作成する**

   **署名の設定:**
   使用中の AI ツール・モデルを自身のコンテキストから判断し、適切な形式で設定する。

   | AI ツール | 署名の例 |
   |----------|---------|
   | Claude Code | `🤖 Generated with [Claude Code](https://claude.com/claude-code)` |
   | GitHub Copilot CLI | `🤖 Generated with GitHub Copilot` |
   | その他 | `🤖 Generated with <ツール名>` |

   ```bash
   gh pr create --draft --title "<タイトル>" --body "$(cat <<'EOF'
   <テンプレートの構成に従って埋めた本文>

   🤖 Generated with <AI ツール名>
   EOF
   )"
   ```

4. **完了したら PR の URL を表示する**

### ガードレール

- 現在のブランチが `main` または `develop` の場合は、PR を作成せずその旨を伝えて中断する
- リモートにプッシュされていない場合は `git push -u origin <branch>` を先に実行する
- PR が既に存在する場合は `gh pr view` で確認してその旨を伝え、作成を行わない
- センシティブな情報（`.env`、パスワード、APIキーなど）が差分に含まれる場合は警告する

