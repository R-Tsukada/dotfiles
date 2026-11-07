const vscode = require('vscode');
const path = require('path');

const pad = n => String(n).padStart(2, '0');

const fs = require('fs');

function resolveVaultRoot() {
  const configured = vscode.workspace.getConfiguration('quickMemo').get('vaultRoot');
  if (configured) return configured;
  const folders = vscode.workspace.workspaceFolders || [];
  const hit = folders.find(f => fs.existsSync(path.join(f.uri.fsPath, 'Journal', 'Daily')));
  if (hit) return hit.uri.fsPath;
  throw new Error('vault が見つからへん。Journal/Daily を含むフォルダを開くか、quickMemo.vaultRoot を設定してな');
}

function dailyNoteUri(now) {
  const root = resolveVaultRoot();
  const y = now.getFullYear();
  const date = `${y}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
  return vscode.Uri.file(path.join(root, 'Journal', 'Daily', String(y), `${date}.md`));
}

async function appendToDiary(text) {
  const now = new Date();
  const uri = dailyNoteUri(now);
  try {
    await vscode.workspace.fs.stat(uri);
  } catch {
    throw new Error(`デイリーノートが見つからへん: ${uri.fsPath}`);
  }
  const doc = await vscode.workspace.openTextDocument(uri);
  const lines = doc.getText().split('\n');

  let h = lines.findIndex(l => /^##\s+Diary\s*$/.test(l));
  const edit = new vscode.WorkspaceEdit();
  const time = `${pad(now.getHours())}:${pad(now.getMinutes())}`;
  const body = text.trim().split('\n').map((l, i) => (i === 0 ? l : '  ' + l)).join('\n');
  const entry = `- ${time} ${body}`;

  if (h === -1) {
    const last = doc.lineCount - 1;
    edit.insert(uri, new vscode.Position(last, doc.lineAt(last).text.length), `\n\n## Diary\n${entry}\n`);
  } else {
    let end = lines.length;
    for (let i = h + 1; i < lines.length; i++) {
      if (/^#{1,2}\s/.test(lines[i])) { end = i; break; }
    }
    let lastNonBlank = h;
    for (let i = h + 1; i < end; i++) {
      if (lines[i].trim() !== '') lastNonBlank = i;
    }
    edit.insert(uri, new vscode.Position(lastNonBlank, lines[lastNonBlank].length), `\n${entry}`);
  }
  await vscode.workspace.applyEdit(edit);
  await doc.save();
}

class MemoView {
  resolveWebviewView(view) {
    this.view = view;
    view.webview.options = { enableScripts: true };
    view.webview.html = html();
    view.webview.onDidReceiveMessage(async msg => {
      if (msg.type === 'back') {
        const ed = vscode.window.activeTextEditor || vscode.window.visibleTextEditors[0];
        if (ed) {
          await vscode.window.showTextDocument(ed.document, {
            viewColumn: ed.viewColumn,
            selection: ed.selection,
            preserveFocus: false
          });
        } else {
          await vscode.commands.executeCommand('workbench.action.focusFirstEditorGroup');
        }
        return;
      }
      if (msg.type !== 'save') return;
      try {
        await appendToDiary(msg.text);
        view.webview.postMessage({ type: 'saved' });
      } catch (e) {
        view.webview.postMessage({ type: 'error', message: String(e.message || e) });
      }
    });
    view.onDidChangeVisibility(() => {
      if (view.visible) view.webview.postMessage({ type: 'focus' });
    });
  }
  focusInput() { this.view && this.view.webview.postMessage({ type: 'focus' }); }
}

function html() {
  const nonce = Math.random().toString(36).slice(2);
  return `<!DOCTYPE html><html><head><meta charset="UTF-8">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'nonce-${nonce}';">
<style>
body{padding:8px;font-family:var(--vscode-font-family);color:var(--vscode-foreground)}
textarea{width:100%;box-sizing:border-box;height:160px;resize:vertical;padding:6px;
  background:var(--vscode-input-background);color:var(--vscode-input-foreground);
  border:1px solid var(--vscode-input-border,transparent);font-family:inherit}
button{margin-top:8px;padding:4px 12px;background:var(--vscode-button-background);color:var(--vscode-button-foreground);border:none;cursor:pointer}
#st{margin-top:8px;font-size:12px;opacity:.8}
</style></head><body>
<textarea id="t" placeholder="今なにしてる？（Cmd+Enterで保存）" autofocus></textarea>
<button id="b">保存</button>
<div id="st"></div>
<script nonce="${nonce}">
const vscode=acquireVsCodeApi();
const t=document.getElementById('t'),st=document.getElementById('st');
function save(){ if(!t.value.trim())return; vscode.postMessage({type:'save',text:t.value}); }
document.getElementById('b').onclick=save;
t.addEventListener('keydown',e=>{ if(e.key==='Escape'){e.preventDefault();vscode.postMessage({type:'back'});return;} if((e.metaKey||e.ctrlKey)&&e.key==='Enter'){e.preventDefault();save();} });
window.addEventListener('message',e=>{
  const m=e.data;
  if(m.type==='saved'){t.value='';st.textContent='保存したで ✔';t.focus();}
  else if(m.type==='error'){st.textContent='エラー: '+m.message;}
  else if(m.type==='focus'){t.focus();}
});
t.focus();
</script></body></html>`;
}

function activate(context) {
  const provider = new MemoView();
  context.subscriptions.push(
    vscode.window.registerWebviewViewProvider('quickMemo.memoView', provider, { webviewOptions: { retainContextWhenHidden: true } }),
    vscode.commands.registerCommand('quickMemo.open', async () => {
      await vscode.commands.executeCommand('quickMemo.memoView.focus');
      provider.focusInput();
    })
  );
}
function deactivate() {}
module.exports = { activate, deactivate };
