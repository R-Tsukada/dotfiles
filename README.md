# dotfiles

個人用の設定ファイル。実体はこのリポジトリに置き、本来のパスへシンボリックリンクを張って使う。

| dotfiles 内パス | 実際のパス | 用途 |
|---|---|---|
| `.config/nvim/` | `~/.config/nvim` | Neovim 設定 |
| `.config/coc/` | `~/.config/coc` | coc.nvim 拡張 |
| `.tmux.conf` | `~/.tmux.conf` | tmux 設定 |
| `vscode/settings.json` | VS Code のユーザー設定（下記） | VS Code 設定・VSCodeVim キーバインド |
| `vscode/extensions/local.*` | `~/.vscode/extensions/local.*` | 自作の VS Code 拡張 |

## VS Code

### 自作拡張

| 拡張 | 機能 | キー（VSCodeVim） |
|---|---|---|
| `local.extract-to-note` | 選択範囲を新しいノートに切り出し、元の場所に `[[wikilink]]` を残す | Visual で `Space o n` |
| `local.quick-memo` | サイドバーのメモ欄に書いた内容を、今日のデイリーノートの `## Diary` に `- HH:MM 内容` の形で追記する | `Space o q`（`Cmd+Enter` で保存、`Esc` でエディタへ戻る） |
| `local.quick-find` | ファイル名のあいまい検索とファイル内の単語検索。どちらもプレビュー付き | `Space f f` / `Space f g` |

前提:

- [VSCodeVim](https://marketplace.visualstudio.com/items?itemName=vscodevim.vim) をインストールしておく（キーバインドは `settings.json` の `vim.*` に書いてある）
- 単語検索には ripgrep を使う。VS Code に同梱された `rg` があればそれを使い、なければ `/opt/homebrew/bin/rg`、`/usr/local/bin/rg`、`PATH` 上の `rg` の順に探す
- クイックメモは、`Journal/Daily` を含むワークスペースフォルダを自動で vault とみなす。別の場所にあるときは、設定 `quickMemo.vaultRoot` に vault のパスを書く

### macOS でのセットアップ

```bash
# ユーザー設定（既存ファイルがあれば退避してから）
CODE_USER="$HOME/Library/Application Support/Code/User"
mv "$CODE_USER/settings.json" "$CODE_USER/settings.json.bak" 2>/dev/null
ln -s ~/dotfiles/vscode/settings.json "$CODE_USER/settings.json"

# 自作拡張（~/.vscode/extensions 全体ではなく、自作分だけをリンクする）
mkdir -p ~/.vscode/extensions
for e in ~/dotfiles/vscode/extensions/local.*; do
  ln -s "$e" ~/.vscode/extensions/"$(basename "$e")"
done
```

最後に VS Code のコマンドパレットから「Developer: Reload Window」を実行する。

### WSL でのセットアップ

Windows の VS Code から Remote - WSL で WSL 内のフォルダを開く使い方を想定している。このとき、設定と拡張の置き場所は次のように分かれる。

- **ユーザー設定**: Windows 側の `%APPDATA%\Code\User\settings.json` にある。WSL に接続しているときもこれが使われる
- **自作拡張**: WSL 側の `~/.vscode-server/extensions/` に置く。ワークスペース側（WSL）で動く拡張として読み込まれる

#### 1. dotfiles を WSL に clone する

```bash
git clone <このリポジトリのURL> ~/dotfiles
```

#### 2. 自作拡張をリンクする（WSL 側）

WSL のフォルダを一度 VS Code で開くと、`~/.vscode-server` が作られる。開いたら、WSL のターミナルで次を実行する。

```bash
mkdir -p ~/.vscode-server/extensions
for e in ~/dotfiles/vscode/extensions/local.*; do
  ln -s "$e" ~/.vscode-server/extensions/"$(basename "$e")"
done
```

#### 3. ripgrep をインストールする（WSL 側）

VS Code Server に同梱された `rg` が見つからないときに備えて入れておく。

```bash
sudo apt install ripgrep
```

#### 4. ユーザー設定を共有する（Windows 側）

Windows の設定ファイルから、WSL 内の dotfiles へシンボリックリンクを張る。PowerShell を管理者で開いて（または開発者モードを有効にして）実行する。`Ubuntu` と `<user>` は自分の環境に合わせる。

```powershell
$settings = "$env:APPDATA\Code\User\settings.json"
Move-Item $settings "$settings.bak" -ErrorAction SilentlyContinue
New-Item -ItemType SymbolicLink -Path $settings `
  -Target "\\wsl.localhost\Ubuntu\home\<user>\dotfiles\vscode\settings.json"
```

うまく読み込めないとき:

- リモート先へのリンクの解決が無効になっていることがある。管理者の PowerShell で `fsutil behavior set SymlinkEvaluation R2L:1` を実行してから試す
- WSL が起動していないと、リンク先を読めない。VS Code より先に WSL を起動しておく
- それでも駄目なら、リンクはやめて `vscode/settings.json` の内容（少なくとも `vim.*` の部分）を Windows 側の設定にコピーする

#### 5. 再読み込みと確認

VS Code で「Developer: Reload Window」を実行し、拡張機能ビューの「WSL: <ディストリ名> - Installed」に自作拡張が出ていれば完了。

クイックメモは、vault（`Journal/Daily` を含むフォルダ）をワークスペースとして開いていれば自動で動く。vault を別の場所に置いているときは、設定 `quickMemo.vaultRoot` に WSL 側のパス（例: `/home/<user>/Obsidian/vault`）を書く。この `settings.json` は macOS と共有しているので、WSL だけで値を変えたいときは、Remote 用の設定（コマンドパレット「Preferences: Open Remote Settings (JSON) (WSL)」）に書く。
