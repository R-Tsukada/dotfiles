const vscode = require('vscode');
const path = require('path');

// Obsidianのファイル名・リンクで使えない文字を除去
function sanitize(name) {
  return name
    .replace(/[\\/:*?"<>|#^\[\]]/g, '')
    .replace(/^\.+/, '')
    .trim();
}

async function exists(uri) {
  try { await vscode.workspace.fs.stat(uri); return true; } catch { return false; }
}

function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand('extractToNote.run', async () => {
      const editor = vscode.window.activeTextEditor;
      if (!editor || editor.selection.isEmpty) {
        vscode.window.showWarningMessage('範囲を選択してから実行してな');
        return;
      }
      const sourceUri = editor.document.uri;
      const selection = editor.selection;
      const text = editor.document.getText(selection);

      const input = await vscode.window.showInputBox({ prompt: '新しいノートのタイトル' });
      if (input === undefined) return;
      const title = sanitize(input);
      if (!title) {
        vscode.window.showWarningMessage('有効なタイトルを入力してな');
        return;
      }

      const dir = path.dirname(sourceUri.fsPath);
      let finalTitle = title;
      let n = 1;
      while (await exists(vscode.Uri.file(path.join(dir, finalTitle + '.md')))) {
        n++;
        finalTitle = `${title} ${n}`;
      }
      const newUri = vscode.Uri.file(path.join(dir, finalTitle + '.md'));
      const sourceName = path.basename(sourceUri.fsPath, path.extname(sourceUri.fsPath));

      const body = `${text.replace(/\s+$/, '')}\n\n---\n元ノート: [[${sourceName}]]\n`;
      await vscode.workspace.fs.writeFile(newUri, Buffer.from(body, 'utf8'));

      // 元ノートの選択範囲をwikilinkに置換
      await editor.edit(eb => eb.replace(selection, `[[${finalTitle}]]`));
      await editor.document.save();

      const doc = await vscode.workspace.openTextDocument(newUri);
      await vscode.window.showTextDocument(doc);
    })
  );
}
function deactivate() {}
module.exports = { activate, deactivate };
