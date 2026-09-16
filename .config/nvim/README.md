# Neovim カスタム操作ガイド

この設定で追加・変更しているキーマップとコマンドの一覧。Vim標準の基本操作は省略しています。

`Space ff` は Space → f → f の順に押します。大文字・小文字は区別します。特記のないキーマップはノーマルモード用です。`Alt` は設定中の `<M-…>` に対応します。

## 操作一覧・編集補助

| キー／コマンド | モード・場所 | 動作 |
| --- | --- | --- |
| `Space ?` / `:KeymapHelp` | ノーマル | 現在のSpaceキーマップとカスタム操作の一覧を表示。`q` / `Esc` で閉じる |
| `Ctrl+s` | ノーマル・挿入 | 保存。挿入モードを維持したまま保存できる |
| `Esc Esc` | ノーマル | 検索ハイライトのON/OFFを切り替える |
| `(` / `{` / `[` / `'` / `"` | 挿入 | 対になる閉じ文字を挿入し、その間にカーソルを置く |
| `r` | Quickfixウィンドウ | `:Qfreplace` を起動し、Quickfixの項目を編集して置換する |

CopilotChatの挿入モードでは `Ctrl+s` は保存ではなく送信になります。

## ファイル検索・ファイルツリー

| キー | コマンド | 動作 |
| --- | --- | --- |
| `Space ff` | `:FzfPreviewProjectFilesRpc` / `:FzfPreviewDirectoryFilesRpc` | Git管理下ではプロジェクト内、管理外では現在のディレクトリ内のファイルを検索（`:pwd`で検索場所を確認） |
| `Space fg` → 検索語 → `Enter` | `:FzfPreviewProjectGrepRpc {検索語}` | プロジェクト内の文字列を検索。`Space fg` の直後はコマンドラインに検索語を入力する |
| `Space fb` | `:FzfPreviewBuffersRpc` | 開いているバッファから選択 |
| `Space fh` | `:FzfPreviewCommandPaletteRpc` | コマンド履歴から選択・実行 |
| `Space e` | `:Fern . -drawer` | 現在の作業ディレクトリをファイルツリーで表示 |
| `Space E` | `:Fern . -drawer -reveal=%` | ファイルツリーを開いて現在のファイルを表示 |

Fernでは隠しファイルを最初から表示します。

## プロジェクト内の検索と置換

`Space fg` は、検索語を渡してからripgrepを実行する操作です。検索結果の画面にある `ProjectGrep>` は、取得済みの結果をさらに絞り込むための入力欄です。

1. `Space fg` を押し、画面下のコマンドラインに検索語を入力して `Enter` を押す。
2. 検索結果で、置換したい行を `Tab` で選択する。複数選択できる。
3. `Ctrl+q` で選択した行をQuickfixへ送る。
4. `:copen` でQuickfixを開き、Quickfix内で `r` を押す。
5. 開いた置換用バッファで内容を編集するか、次のように置換コマンドを実行する。

   ```vim
   :%s/oldName/newName/gc
   ```

   `g` は行内のすべてを対象にし、`c` は1件ずつ確認します。確認では `y` で置換、`n` でスキップします。確認なしなら `:%s/oldName/newName/g` を使います。

6. 置換結果を確認して `:w`。選択した検索結果に対応する元ファイルへ反映・保存される。

全検索結果を対象にしたい場合は、fzf画面で `Ctrl+a` で全選択してから `Ctrl+q` を押します。バッファ一覧の `Space fb` では `Ctrl+q` の意味が異なるため、この置換フローには使いません。

## Markdownプレビュー（md-render.nvim）

| キー | コマンド | 動作 |
| --- | --- | --- |
| `Space mp` | `:MdRender` | フローティングプレビューを開閉 |
| `Space mt` | `:MdRender tab` | 別タブでプレビュー |
| `Space ms` | `:vert MdRender split` | ソースとプレビューを左右に並べる。編集とスクロールを同期 |
| `Space md` | `:MdRender demo` | 対応記法のデモを表示 |

プレビュー内は `Enter` / `za` で折りたたみを切り替え、フローティング・タブ表示は `q` / `Esc` で閉じます。

Neovim 0.12以上が必要です。md-render.nvimと日本語の折り返しを補助するbudoux.luaはLazy管理です。プラグインを手動でcloneする必要はありません。

見出し・表・リスト・リンクなどはNvim内で表示します。画像・動画にはKitty graphics protocol対応ターミナル（Ghostty、Kitty、WezTermなど）が必要です。動画はFFmpeg、Mermaid図はMermaid CLI（未導入ならnpx経由で取得）を使用します。通常の文章プレビューのために、これらの追加ツールを一括インストールする必要はありません。

## Markdownの箇条書き入力

`bullets.vim`をLazyで管理しています。Markdownと `Space oq` のメモ入力欄で有効です。

| 操作（挿入モード） | 動作 |
| --- | --- |
| 項目を書いて `Enter` | `-` / `*` / `+` の箇条書きを継続。番号付きリストは次の番号を挿入 |
| `Ctrl+t` | 項目を1段深くする（子リストにする） |
| `Ctrl+d` | 項目を1段浅くする |
| 空の項目で `Enter` | 子リストなら1段戻り、最上位なら箇条書きを終了 |

改行時は現在の階層を維持し、項目間に空行は追加しません。階層変更時はプラグインの規則に従って記号や番号の形式も変わる場合があります。

## 定義ジャンプ（TypeScript / Playwright POM）

| キー | 動作 |
| --- | --- |
| `gd` | カーソル下の関数・メソッド・クラス・変数の定義へジャンプ（Coc） |
| `Ctrl+o` | ジャンプ前の場所へ戻る |
| `Ctrl+i` | ジャンプ履歴を進む |

PlaywrightでPOM（Page Object Model）を使う場合、テスト内の `await loginPage.login()` の `login` にカーソルを合わせて `gd` を押すと、型が解決できる場合はPage Object側のメソッド定義へ移動できます。`new LoginPage(page)` の `LoginPage` でも定義へ移動できます。確認後は `Ctrl+o` でテストに戻ります。Spaceを付けず、ノーマルモードで `g` → `d` の順に押します。

`coc-tsserver` がTypeScriptの型情報を使います。初回は言語サーバーの起動を待ってください。移動できない場合はimport先・型情報・プロジェクトの `tsconfig.json` を確認し、`:CocList extensions` / `:CocInfo` で拡張の状態やエラーを確認できます。コマンドで実行する場合は `:call CocActionAsync('jumpDefinition')` です。

## アウトライン（TypeScript / TSX / Markdown）

| キー | コマンド | 動作 |
| --- | --- | --- |
| `Space fo` | `:CocCommand fzf-preview.CocOutline` | 現在のファイルのアウトラインをfzfで検索。選択候補のコードをプレビューし、Enterで移動 |
| `Space fO` | `:CocOutline` | 現在のファイルのアウトラインをサイドバーに表示 |

TypeScript / TSXでは関数・クラス・interfaceなど、Markdownでは見出しとその階層が対象です。fzf画面では `Ctrl+d` / `Ctrl+u` でプレビューをスクロール、`?` でプレビュー表示を切り替えます。サイドバー内では `Enter` で移動、`t` で展開・折りたたみ、`f` で絞り込み、`Esc` で閉じます。

対応拡張は `coc-tsserver`、`@yaegassy/coc-marksman`、`coc-fzf-preview` です。`lua/plugins/coc.lua` の `coc_global_extensions` に登録しているため、別環境でも未導入の拡張をCoc起動時にインストールします。Marksman本体はPATH上になければ拡張がダウンロードします。Universal Ctagsはこの方式では不要です。

初回は言語サーバーの起動を待ってから操作してください。表示されない場合は `:CocList extensions` で拡張の状態、`:CocInfo` でエラーを確認できます。

## バッファ・Git・ターミナル

| キー／コマンド | 動作 |
| --- | --- |
| `Space n` | 次のバッファ |
| `Space p` | 前のバッファ |
| `Space bd` | 現在のバッファを閉じる（ファイルの削除ではない） |
| `Space gg` / `:LazyGit` | LazyGitを開く |
| `Ctrl+\` | ToggleTermのターミナルを開閉。縦分割・画面幅の40% |
| `:T` | 下側に高さ20行のターミナルを新規作成 |
| `:T npm run dev` | 下側のターミナルで指定コマンドを実行 |
| ターミナル内の `Esc` | ターミナル入力モードを抜ける |

## Copilot補完

挿入モードで使用します。自動提案はOFFです。Markdown・YAML・help・Gitコミットメッセージなどでは補完を無効にしています。

| キー | 動作 |
| --- | --- |
| `Alt+]` | 次の提案 |
| `Alt+[` | 前の提案 |
| `Alt+l` | 提案を採用 |
| `Ctrl+]` | 提案を閉じる |
| `Alt+Enter` | 候補パネルを開く |

候補パネル内のカスタムキー：`[[` / `]]` で前後の候補、`Enter` で採用、`gr` で更新。パネルは下側・高さ40%です。

MacのOptionキーで反応しない場合は、使用しているターミナルのAlt/Meta送信設定を確認してください。

## CopilotChat

| キー | コマンド | 動作 |
| --- | --- | --- |
| `Space cc` | `:CopilotChat` | チャットを開く |
| `Space cb` | `:CopilotChat #buffer:current` | 現在のバッファを指定してチャット |
| 選択中に `Space cs` | `:CopilotChat #selection` | 選択範囲を指定してチャット |
| `Space ce` | `:CopilotChatExplain` | コードの説明 |
| `Space cr` | `:CopilotChatReview` | コードレビュー |
| `Space cf` | `:CopilotChatFix` | 修正を依頼 |
| `Space co` | `:CopilotChatOptimize` | 最適化を依頼 |

追加のカスタムプロンプト：

| コマンド | 動作 |
| --- | --- |
| `:CopilotChatTests` | 単体テストの作成を依頼 |
| `:CopilotChatDocs` | コメント形式のドキュメント作成を依頼 |
| `:CopilotChatFixDiagnostic` | 診断情報を使って修正を依頼 |
| `:CopilotChatDebugBuffer` | 現在のバッファ番号・名前・有効性・読み込み状態を表示 |

チャットは縦分割・幅50%、自動で挿入モードに入ります。回答は日本語・関西弁、温度は0.1に設定しています。チャット内の送信は挿入モードで `Ctrl+s`、ノーマルモードで `Enter` です。

## Sidekick（AI CLI）

| キー | 動作 |
| --- | --- |
| `Space aa` | AI CLIを開閉 |
| `Space as` | CLIツールを選択 |
| `Space ap` | プロンプトを選択 |

マルチプレクサ連携は有効で、バックエンドはtmuxです。

## Playwright / neotest

| キー | 動作 |
| --- | --- |
| `Space tt` | カーソル付近のテストを実行 |
| `Space tf` | 現在のファイルのテストを実行 |
| `Space ts` | テスト一覧・結果を開閉 |
| `Space to` | テスト出力を開いて移動 |
| `Space tu` | Playwright UIを起動（`:NeotestRunNearestUI`） |
| `Space tp` | プロジェクト選択（`:NeotestPlaywrightProject`） |
| `Space tP` | プリセット選択（`:NeotestPlaywrightPreset`） |
| `Space tra` | テスト検出を更新（`:NeotestPlaywrightRefresh`） |
| `Space ta` | trace・動画などの添付を表示 |
| `Space tw` | カーソル付近のテストの監視を切り替え |
| `Space tW` | 現在のファイルのテストの監視を切り替え |

| 追加コマンド | 動作 |
| --- | --- |
| `:NeotestLogPath` | neotestログのパスを表示 |
| `:NeotestPlaywrightToggleQuiet` | Playwrightのquiet設定を切り替えて再設定。初期値はON |
| `:NeotestRunNearestUI` | 現在のファイルをPlaywright UIで開く。カーソル行に `test(...)` / `describe(...)` の名前があれば絞り込みを試みる |

通常のneotest実行はファイル位置からPlaywrightのルートを推定します。UI起動は独自のコマンド生成処理を使い、現在の作業ディレクトリで実行します。UIのテスト名絞り込みは引用符処理に既知の懸念があり、未修正です。

`Space td` はDAPの動作確認まで未割り当てです。`Space tP` はプリセット選択画面を開く操作で、直接デバッグ・headed実行するキーではありません。

## Obsidian

### 日次ノートへメモを記録する

`Space oq` または `:ThinoCapture` で右側に入力サイドバーを開きます。どのファイルを編集していても利用できます。

1. サイドバーにメモを書く。複数行も入力できます。
2. `Ctrl+s`（挿入・ノーマル両対応）または `:w` で、保存時点の今日の日次ノートへ記録します。
3. 記録成功後は入力欄が空になり、続けて次のメモを書けます。

日次ノートの `## Diary` セクション末尾へ `- HH:MM 内容` 形式で追記します。2行目以降はインデントして同じメモに含めます。見出しがなければ追加し、その日のファイルがなければobsidian.nvimの日次テンプレート設定で作成します。

記録先は既存のVault・日次フォルダ設定を使用します。見出しは環境変数 `OBSIDIAN_CAPTURE_HEADING` で変更でき、未設定なら `## Diary`、空文字ならファイル末尾へ追記します。

ノーマルモードの `q` で入力欄を閉じます。未送信の下書きは同じNvimセッション内に保持し、`Space oq` で再表示できます（Nvim終了後の復元には非対応）。入力だけでは日次ノートに保存されません。

今日の日次ノートに未保存の編集があっても、その内容を保持してメモを追記し、日次ノート全体を保存します。連続して記録できます。失敗した場合は日次ノートの既存編集と入力欄のメモを残します。現在編集している別ファイルは保存せず、日次ノートを画面に開く必要もありません。

| キー | コマンド | 動作 |
| --- | --- | --- |
| `Space on` | `:ObsidianNew` | 新規ノート |
| `Space oo` | `:ObsidianOpen` | Obsidianアプリで開く |
| `Space of` | `:ObsidianQuickSwitch` | ノート名で検索 |
| `Space os` | `:ObsidianSearch` | ノートの内容を検索 |
| `Space ot` | `:ObsidianToday` | 今日のデイリーノート |
| `Space oy` | `:ObsidianYesterday` | 昨日のデイリーノート |
| `Space om` | `:ObsidianTomorrow` | 明日のデイリーノート |
| `Space ob` | `:ObsidianBacklinks` | バックリンク一覧 |
| `Space ol` | `:ObsidianLinks` | リンク一覧 |
| `Space oc` | `:ObsidianToggleCheckbox` | チェックボックス切り替え |
| 選択中に `Space ol` | `:ObsidianLink` | 選択範囲をリンク化 |
| 選択中に `Space on` | `:ObsidianExtractNote` | 選択範囲を新規ノートに抽出 |

Vaultは環境変数 `OBSIDIAN_VAULT_PATH` で指定します。この変数が未設定だとプラグイン設定の読み込みでエラーになります。

- デイリーノートの保存先：`OBSIDIAN_DAILY_NOTES_FOLDER`。未設定時は `valut_cloud/Daily`
- デイリーノートのテンプレート：`DailyNoteTemplate.md`
- テンプレートフォルダ：`Config/Templates`
- 新規ノートの保存先：現在のバッファのディレクトリ
- ノートID：タイトル指定時はタイトル、未指定時はタイムスタンプ
- ノート選択UI：Telescope

複数のPCで使う場合は、各PCのシェル設定でVaultの絶対パスと日次ノート用のVault内相対パスを設定します。たとえばzshでは次のように設定します。

```zsh
export OBSIDIAN_VAULT_PATH="/Users/あなたの名前/…/valut"
export OBSIDIAN_DAILY_NOTES_FOLDER="valut_cloud/Daily"
```

`OBSIDIAN_DAILY_NOTES_FOLDER` はVaultからの相対パスです。Vaultの場所だけがPCごとに違うなら、`OBSIDIAN_VAULT_PATH` だけを変更すれば同じ設定を共有できます。設定を変更した後は、新しいターミナルを開いてからNvimを起動します。

## 別PCでTreesitterの設定読み込みに失敗する場合

`module 'nvim-treesitter.configs' not found` は、現在の旧API向け設定に対して新版Treesitterが入っている場合に発生します。この設定では `branch = 'master'` を明示しています。設定を取得した後、Nvimで `:Lazy update nvim-treesitter` を実行し、完了後に再起動してください。

Neovim 0.11では旧版のAPIを使用し、0.12では `config.treesitter-compat` がクエリ処理を補います。Neovim本体を更新するだけでは、Treesitterのブランチの不一致は解消しません。Markdownプレビューの `md-render.nvim` はNeovim 0.12以上が必要です。Homebrewで導入している場合、本体は `brew update` → `brew upgrade neovim` で更新できます。

## キー変更の対応表

| 以前のキー | 現在のキー |
| --- | --- |
| `Space b` | `Space p`（前のバッファ） |
| `Space ttu` | `Space tu`（Playwright UI） |
| `Space tpr` / `Space th` / `Space tdb` | `Space tP`（プリセット選択） |

`m` と `;` のプレフィックス上書きは削除済みです。Cocには現在、独自の定義ジャンプ・リネームなどのキーマップを追加していません。
