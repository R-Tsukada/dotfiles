# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

個人用 dotfiles リポジトリ（`~/dotfiles/`）。シンボリックリンクで各設定を本来のパスに配置している。

| dotfiles 内パス | 実際のパス | 用途 |
|---|---|---|
| `.config/nvim/` | `~/.config/nvim` | Neovim 設定 |
| `.config/coc/` | `~/.config/coc` | coc.nvim 拡張 |
| `.tmux.conf` | `~/.tmux.conf` | tmux 設定 |

新しい設定を追加するときは、dotfiles 内に置いてシンボリックリンクを張る：
```bash
ln -s ~/dotfiles/.config/<name> ~/.config/<name>
```

## Structure

```
.config/nvim/
├── init.lua                  # エントリポイント。options/lazy/keymaps を読み込み
├── lazy-lock.json            # プラグインバージョンロックファイル
└── lua/
    ├── config/
    │   ├── options.lua       # Vim オプション設定（インデント・クリップボード等）
    │   ├── lazy.lua          # lazy.nvim ブートストラップ & プラグインロード
    │   ├── keymaps.lua       # 共通キー・操作一覧・Thino入力欄（<Leader>=Space）
    │   └── neotest-setup.lua # Neotest + neotest-playwright 詳細設定（パッチ含む）
    └── plugins/              # プラグインごとの設定ファイル（lazy.nvim spec 形式）
```

## Key Architecture Decisions

### Plugin Manager
lazy.nvim を使用。`lua/config/lazy.lua` でブートストラップし、`lua/plugins/` 配下の全ファイルを自動インポート。

### Key Prefixes
- `<Leader>` (Space) — 汎用プレフィックス
- `<LocalLeader>` (バックスラッシュ) — ローカルプレフィックス
- `gd` — Cocの定義ジャンプ
- `Space fo/fO` — アウトライン検索・表示

旧説明のLSP用`m`とfzf用`;`は現在の共通設定にはありません。詳細な操作説明は`.config/nvim/README.md`を参照してください。

### Plugin Overview

| プラグイン | 用途 | 主なキーマップ |
|---|---|---|
| coc.nvim | LSP/補完 | — |
| claudecode.nvim + snacks.nvim | Claude Code CLI連携 | `<leader>ac/af/ar/aC/am/ab/as/aa/ad` |
| fzf-preview.vim | ファジーファインダー | `<leader>ff/fg/fb/fh` |
| fern.vim | ファイルツリー | `<leader>e/E` |
| lazygit.nvim | Git UI | `<leader>gg` |
| neotest + neotest-playwright | テスト実行 | `<leader>tt/tf/ts/to/tu` |
| toggleterm.nvim | ターミナル | `<C-\>` |
| bufferline.nvim | バッファタブ | `<leader>n/p/bd` |
| obsidian.nvim | Obsidian ノート | `<leader>on/oo/of/os/ot` |
| lualine.nvim | ステータスライン | — |
| markview.nvim | Markdown装飾・分割表示 | `<leader>mp/ms` |
| bullets.vim | Markdown・Thino入力欄の箇条書き | Enter等 |
| indent-blankline.nvim（ibl） | インデントガイド | — |

カラースキームはtokyonight-vimです。ほかにDAP関連、vim-qfreplaceを`plugins/migrated.lua`で定義しています。Coc拡張は`coc-tsserver`、`@yaegassy/coc-marksman`、`coc-fzf-preview`を設定から追加します。AI連携は`plugins/claudecode.lua`で定義します。Claude Code CLIがPATH上に必要で、各PCで認証してください。Copilot、CopilotChat、Sidekick、MCPHubは削除済みです。`Space ac`で開閉、`af`で移動、`ar/aC`で再開、`am`でモデル選択、`ab`でファイル追加、選択モードの`as`で範囲送信、`aa/ad`で差分承認・却下。`:ClaudeCodeStatus`で状態確認できます。

### Neotest / Playwright Integration
`neotest-setup.lua`は`plugins/neotest.lua`の`VeryLazy`イベントから読み込みます。複雑なパッチロジックを含みます：
- `playwright.get_config()` をパッチして dotenv の stdout ノイズを除去
- `discover_positions`と`build_spec`の作業ディレクトリを調整してPlaywright設定を探索
- 非同期処理を呼び出し元のコンテキストに合わせて実行
- `neotest.lib.subprocess` を無効化して親プロセスで確実に処理

### Obsidian Vault
`OBSIDIAN_VAULT_PATH` 環境変数が必須。未設定だと起動時にエラーが出る。

| 環境変数 | 用途・既定値 |
| --- | --- |
| `OBSIDIAN_VAULT_PATH` | 必須。Vaultのパス |
| `OBSIDIAN_DAILY_NOTES_FOLDER` | Vault内の日次ノートフォルダ。既定は`Journal/Daily` |
| `OBSIDIAN_CAPTURE_HEADING` | メモ挿入先。既定は`## Diary`。空文字なら末尾に追記 |

PC固有のVault絶対パスを設定に埋め込まないでください。旧`valut_cloud/Daily`は使いません。テンプレートは`Config/Templates/DailyNoteTemplate.md`です。通常の新規・抽出ノートは、タイトルにサブフォルダを指定しない限りVault直下です。ノートIDにはタイトルを使い、タイトルなしの場合は時刻に基づく値です。ノート選択はTelescopeです。

`Space ot/oy/om`で今日・昨日・明日、`Space ob/ol/oc`でバックリンク・リンク一覧・チェック切替。選択モードの`Space ol/on`はリンク作成・ノート抽出です。

### Vaultリンク補完

`autoload/coc/source/vault.vim`と`lua/config/vault-completion.lua`がCoc独自の`[Vault]`ソースを提供します。Markdown・`thino-capture`で、`[[`の後に2文字以上入力すると非同期検索します。空の検索で全Vaultを読み込むことを防いでいます。最小文字数は`vim.g.vault_completion_min_chars`（既定2）で変更できます。

検索は大文字・小文字を区別せず、ファイル名やaliasesに対応します。リンク先はVault内の相対パスで、閉じ括弧を重複させません。補完でノートは新規作成しません。`Ctrl+n/p`で選択、`Ctrl+y`で確定し、Enterは箇条書き入力に使います。Node.js・ripgrep・Vault環境変数が必要です。

### Thinoメモ入力

`Space oq`または`:ThinoCapture`で右側に入力欄を開きます。実装は`lua/config/thino-capture.lua`です。`Ctrl+s`または`:w`で送信時点の今日の日次ノートに`- HH:MM 本文`形式で追記・保存します。複数行の後続行はインデントします。既存の未保存編集も含めて追記し、保存失敗時は変更を戻して下書きを保持します。通常モードの`q`で下書きを保持して閉じます。

### Markdown表示とTree-sitter

markview.nvimを`lazy = false`で読み込みます。md-render.nvimとbudoux.luaは削除済みです。`Space mp`でインライン表示を切替、`Space ms`で左右分割表示を切替。Markviewがプレビュー状態に応じて`conceallevel`を制御するため、通常のMarkdownに常時`conceallevel=0`を強制しないでください。Thino入力欄は装飾なしを維持し、Obsidian独自UIは`ui.enable = false`です。

コールアウトはMarkdownの`> [!TIP]`や`> [!INFO]`を使います。`TIP: 本文`はAsciiDoc用で、`.md`ではコールアウトになりません。全種類と使用例はNeovimのREADMEを参照してください。Mermaidの図はObsidianアプリで確認します。

nvim-treesitterは旧APIの`configs.setup`に合わせて`branch = 'master'`を固定します。対象パーサーは`typescript`、`tsx`、`markdown`、`markdown_inline`、`yaml`、`auto_install = false`です。Neovim 0.12では`lua/config/treesitter-compat.lua`が互換処理を適用します。

### 共通操作・tmux

通常・挿入モードの`Ctrl+s`で保存、`Space ?`または`:KeymapHelp`で操作一覧を表示します（`lua/config/keymap-help.lua`）。`:T`は下側のターミナルを開きます。選択範囲のノート操作は`lua/config/obsidian-selection.lua`を参照してください。

tmuxは`tmux-256color`、True Color、vi形式のコピーモード、10,000行の履歴を設定します。ウィンドウとペインは1始まり。標準prefixの後の`|`と`-`で左右・上下分割します。Claude Codeのターミナル連携はsnacks.nvimを使用します。

### WSL 対応
`options.lua` に WSL クリップボード設定（win32yank 経由）を含む。macOS では自動スキップ。

## Common Operations

### プラグインの追加・変更
`lua/plugins/` に新しい `.lua` ファイルを作成するか既存ファイルを編集。lazy.nvim が自動検出する。

### プラグインバージョン更新
Neovim 内で `:Lazy update` を実行。`lazy-lock.json` が更新される。

### テスト実行（Neovim 内）
- `<leader>tt` — カーソル位置のテストを実行
- `<leader>tf` — 現在ファイルのテストを実行
- `<leader>ts` — テストサマリーを表示/非表示
- `<leader>tu` — カーソル位置のテストを Playwright UI モードで実行
- `<leader>to` — テスト結果を表示
- `<leader>tp/tP` — Playwrightプロジェクト設定・プリセット
- `<leader>tra` — Playwright情報を更新
- `<leader>ta` — 添付情報を表示
- `<leader>tw/tW` — 近傍・ファイルのwatchを切替
- `:NeotestPlaywrightToggleQuiet` — Playwright quiet モードのトグル

### 変更後の確認

設定やキー・環境変数の変更時は`.config/nvim/README.md`とこのファイルも更新します。プラグイン更新時は`lazy-lock.json`に無関係な更新が混ざっていないか確認してください。`.config/coc/`には`mru`・`memos.json`などのデータもあり、設定と区別して扱います。

起動確認はVault環境変数を読み込んだ環境で`nvim --headless +qa`、Markviewの診断は`:checkhealth markview`を使います。機能変更は該当操作で確認し、コミット前には`git diff --check`と差分を確認します。
