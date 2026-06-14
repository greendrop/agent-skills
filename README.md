# agent-skills

AI エージェント向けスキル（プロンプト）を管理・配布するリポジトリ。

## スキル一覧

[docs/skills.md](docs/skills.md) を参照。

## スキルのインストール

```bash
gh skill install github.com/greendrop/agent-skills
```

## スキルの更新

```bash
gh skill update --all
```

## 開発

ツール管理には [mise](https://mise.jdx.dev/) を使用する。

```bash
# ツールをインストールする（lefthook install も自動実行）
mise install

# すべての SKILL.md を検証する
mise run skills:validate

# 特定の SKILL.md を検証する
mise run skills:validate:one greendrop-git-conventional-commit/SKILL.md
```

`mise install` 実行後、[lefthook](https://github.com/evilmartians/lefthook) による Git フックが有効になり、コミット前に [betterleaks](https://github.com/betterleaks/betterleaks) で秘密情報（API キー・パスワード等）が検出される。PR 時にも GitHub Actions（`secret-scan`）で同様のチェックが実行される。

### 新しいスキルの追加

1. `<skill-name>/SKILL.md` を作成する
2. 以下の frontmatter を先頭に記述する

   ```markdown
   ---
   name: <skill-name> # 親ディレクトリ名と一致させること
   description: スキルの説明
   version: "YYYY.MM.DD.N" # CalVer 形式 (例: 2026.04.29.1)
   source: "github.com/greendrop/agent-skills"
   ---
   ```

3. `mise run skills:validate` でローカル検証
4. PR を作成 → main にマージされると自動でパブリッシュされる

## 参考

- [Agent Skills](https://agentskills.io/)
