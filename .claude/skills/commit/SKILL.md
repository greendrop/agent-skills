---
description: 変更を確認し、意味のある単位に分けて Conventional Commits 形式でコミットを作成する
metadata:
    github-path: commit
    github-ref: refs/tags/v2026.04.29.1
    github-repo: https://github.com/greendrop/agent-skills
    github-tree-sha: 62a4e87a0caded5a1a55a4242db145d8ed47ce17
name: commit
source: github.com/greendrop/agent-skills
version: 2026.04.29.3
---
`general-purpose` サブエージェントを起動し、以下の「サブエージェントへのプロンプト」セクションの内容をそのままプロンプトとして渡して実行させてください。サブエージェントの実行結果をユーザーに表示してください。

---

## サブエージェントへのプロンプト

変更を確認して git コミットを作成してください。

### 手順

1. **現在の状態を確認する**（並列実行）
   - `git branch --show-current` — 現在のブランチ名
   - `git status` — 変更ファイルの一覧
   - `git diff` — 未ステージの差分
   - `git diff --staged` — ステージ済みの差分
   - `git log --oneline -5` — 直近のコミットメッセージ（スタイル確認用）

   ブランチ名が `main` または `develop` であれば、コミットは行わずその旨を伝えて中断する。

2. **変更内容を分析し、コミット単位に分割する**

   ファイルを「意味のあるまとまり」ごとにグループ化する。グループ化の基準:
   - 同じ目的・理由で変更されたファイル（例: 同じ機能の追加、同じバグの修正）
   - 関係のない変更は別コミットにする（例: 機能追加と依存更新は分ける）
   - 1ファイルのみの変更でも、目的が異なれば別コミットにする

   グループが1つの場合も、この分析を行う。

3. **コミットを順番に実行する**

   各コミットについて:

   a. 対象ファイルをステージする
      ```bash
      git add <file1> <file2> ...
      ```
      - `.env` や認証情報ファイルは**絶対にステージしない**

   b. コミットを作成する（HEREDOC を使う）
      ```bash
      git commit -m "$(cat <<'EOF'
      type(scope): subject（日本語）

      詳細（不要なら省略）

      Co-Authored-By: <AI ツール名とモデル名> <メールアドレス>
      EOF
      )"
      ```

   c. 成功を確認してから次のコミットへ進む

5. **すべて完了したら結果を表示する**

   作成したコミットの一覧（ハッシュ・メッセージ）を表示する。

### コミットメッセージの形式

**Conventional Commits** 形式を使用する:

**Co-Authored-By の設定:**
使用中の AI ツール・モデルを自身のコンテキストから判断し、適切な形式で設定する。

| AI ツール | Co-Authored-By の例 |
|----------|---------------------|
| Claude Code (Sonnet 4.6) | `Claude Sonnet 4.6 <noreply@anthropic.com>` |
| Claude Code (Opus 4.7) | `Claude Opus 4.7 <noreply@anthropic.com>` |
| GitHub Copilot CLI | `GitHub Copilot <copilot@github.com>` |
| その他 | `<ツール名> <公式メールアドレスまたは noreply>` |

```
<type>(<scope>): <subject>

必要であれば詳細を記述する。
複数行になってもよい。
```

**type の選択:**
| type | 用途 |
|------|------|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `chore` | ビルド・ツール・依存関係の変更 |
| `refactor` | 機能変更を伴わないコード改善 |
| `docs` | ドキュメントのみの変更 |
| `style` | フォーマット・空白など（ロジック変更なし） |
| `test` | テストの追加・修正 |
| `perf` | パフォーマンス改善 |
| `ci` | CI/CD 設定の変更 |

**scope:** 変更に関係するディレクトリ名・機能名・モジュール名。リポジトリ全体に関わる場合は省略可。

**ルール:**
- `<subject>` は日本語で記述する
- クラス名・メソッド名・変数名・ファイル名など、コード内で使われている識別子はそのまま使う（無理に日本語訳しない）
- `<subject>` は簡潔に（体言止め推奨・72文字以内）
- 詳細が必要な場合のみ、空白行を挟んで本文を追加する
- 末尾にピリオドをつけない

### ガードレール

- 現在のブランチが `main` または `develop` の場合は、コミットせずにその旨を伝えて中断する
- `--no-verify` は使用しない
- 空のコミットは作成しない（変更がない場合はその旨を伝える）
- センシティブなファイル（`.env`、`*.key`、`credentials.*`）を含む場合は警告する
- pre-commit フックが失敗した場合は原因を調査して修正し、新しいコミットを作成する（`--amend` は使わない）
- 1コミットが失敗した場合は中断し、原因を報告してからユーザーの指示を待つ

