const vscode = require('vscode');
const path = require('path');

const EXCLUDE = '{**/.git/**,**/.obsidian/**,**/node_modules/**,**/.trash/**,**/vendor/**}';

async function collect() {
  const uris = await vscode.workspace.findFiles('**/*', EXCLUDE, 5000);
  const items = await Promise.all(uris.map(async uri => {
    let mtime = 0;
    try { mtime = (await vscode.workspace.fs.stat(uri)).mtime; } catch {}
    const rel = vscode.workspace.asRelativePath(uri, false);
    const dir = path.dirname(rel);
    return {
      label: path.basename(rel),
      description: dir === '.' ? '' : dir,
      uri,
      mtime
    };
  }));
  // 更新が新しい順
  return items.sort((a, b) => b.mtime - a.mtime);
}

async function run() {
  const original = vscode.window.activeTextEditor;
  const qp = vscode.window.createQuickPick();
  qp.placeholder = 'ファイル名であいまい検索（↑↓でプレビュー）';
  qp.matchOnDescription = true;
  qp.busy = true;
  qp.show();

  let accepted = false;
  let seq = 0;

  qp.onDidChangeActive(async active => {
    const item = active[0];
    if (!item || !item.uri) return;
    const my = ++seq;
    try {
      const doc = await vscode.workspace.openTextDocument(item.uri);
      if (my !== seq) return;
      await vscode.window.showTextDocument(doc, { preview: true, preserveFocus: true });
    } catch { /* バイナリ等はプレビューしない */ }
  });

  qp.onDidAccept(async () => {
    const item = qp.selectedItems[0];
    if (!item || !item.uri) return;
    accepted = true;
    qp.hide();
    const doc = await vscode.workspace.openTextDocument(item.uri);
    await vscode.window.showTextDocument(doc, { preview: false });
  });

  qp.onDidHide(async () => {
    qp.dispose();
    if (!accepted && original) {
      await vscode.window.showTextDocument(original.document, {
        viewColumn: original.viewColumn,
        selection: original.selection,
        preview: false
      });
    }
  });

  qp.items = await collect();
  qp.busy = false;
}


const fs = require('fs');
const cp = require('child_process');

const RG_GLOBS = ['!.git', '!.obsidian', '!node_modules', '!.trash', '!vendor'];
const MAX_RESULTS = 1000;

function findRg() {
  const root = vscode.env.appRoot;
  const candidates = [
    path.join(root, 'node_modules', '@vscode', 'ripgrep', 'bin', 'rg'),
    path.join(root, 'node_modules.asar.unpacked', '@vscode', 'ripgrep', 'bin', 'rg'),
    '/opt/homebrew/bin/rg',
    '/usr/local/bin/rg'
  ];
  return candidates.find(c => { try { return fs.existsSync(c); } catch { return false; } }) || 'rg';
}

function runGrep() {
  const folder = vscode.workspace.workspaceFolders && vscode.workspace.workspaceFolders[0];
  if (!folder) {
    vscode.window.showWarningMessage('ワークスペースを開いてから使ってな');
    return;
  }
  const cwd = folder.uri.fsPath;
  const rg = findRg();
  const original = vscode.window.activeTextEditor;

  const qp = vscode.window.createQuickPick();
  qp.placeholder = '単語を入力（↑↓でプレビュー / Enterで開く）';
  qp.matchOnDescription = false;
  qp.show();

  let proc = null;
  let gen = 0;
  let timer = null;
  let accepted = false;
  let previewSeq = 0;

  const kill = () => { if (proc) { try { proc.kill(); } catch {} proc = null; } };

  function search(query) {
    kill();
    const myGen = ++gen;
    if (!query.trim()) { qp.items = []; qp.busy = false; qp.title = undefined; return; }
    qp.busy = true;
    const args = ['--line-number', '--column', '--no-heading', '--color', 'never',
      '--smart-case', '--fixed-strings', '--max-columns', '300', '--max-columns-preview'];
    RG_GLOBS.forEach(g => args.push('-g', g));
    args.push('--', query, '.');
    const p = cp.spawn(rg, args, { cwd });
    proc = p;
    const items = [];
    let buf = '';
    p.stdout.on('data', chunk => {
      buf += chunk.toString('utf8');
      const lines = buf.split('\n');
      buf = lines.pop();
      for (const line of lines) {
        const m = /^(.+?):(\d+):(\d+):(.*)$/.exec(line);
        if (!m) continue;
        const rel = m[1].replace(/^\.\//, '');
        const ln = Number(m[2]);
        const raw = m[4];
        const caseSensitive = /[A-Z]/.test(query);
        const idx = caseSensitive ? raw.indexOf(query) : raw.toLowerCase().indexOf(query.toLowerCase());
        items.push({
          label: `${path.basename(rel)}:${ln}: ${m[4].trim()}`,
          description: path.dirname(rel) === '.' ? '' : path.dirname(rel),
          alwaysShow: true,
          uri: vscode.Uri.file(path.join(cwd, rel)),
          line: ln - 1,
          col: Math.max(idx, 0),
          len: query.length
        });
        if (items.length >= MAX_RESULTS) { kill(); break; }
      }
    });
    p.on('error', e => {
      if (myGen !== gen) return;
      qp.busy = false;
      vscode.window.showErrorMessage('ripgrep を起動できへん: ' + e.message);
    });
    p.on('close', () => {
      if (myGen !== gen) return;
      proc = null;
      qp.items = items;
      qp.busy = false;
      qp.title = `${items.length}${items.length >= MAX_RESULTS ? '+' : ''} 件`;
    });
  }

  async function reveal(item, preview) {
    const doc = await vscode.workspace.openTextDocument(item.uri);
    const start = new vscode.Position(item.line, item.col);
    const end = new vscode.Position(item.line, item.col + item.len);
    const ed = await vscode.window.showTextDocument(doc, {
      preview,
      preserveFocus: preview,
      selection: new vscode.Range(start, end)
    });
    ed.revealRange(new vscode.Range(start, end), vscode.TextEditorRevealType.InCenter);
  }

  qp.onDidChangeValue(v => {
    clearTimeout(timer);
    timer = setTimeout(() => search(v), 200);
  });

  qp.onDidChangeActive(async active => {
    const item = active[0];
    if (!item || !item.uri) return;
    const my = ++previewSeq;
    try {
      if (my === previewSeq) await reveal(item, true);
    } catch {}
  });

  qp.onDidAccept(async () => {
    const item = qp.selectedItems[0] || qp.activeItems[0];
    if (!item || !item.uri) return;
    accepted = true;
    qp.hide();
    await reveal(item, false);
  });

  qp.onDidHide(async () => {
    clearTimeout(timer);
    kill();
    qp.dispose();
    if (!accepted && original) {
      await vscode.window.showTextDocument(original.document, {
        viewColumn: original.viewColumn,
        selection: original.selection,
        preview: false
      });
    }
  });
}

function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand('quickFind.open', run),
    vscode.commands.registerCommand('quickFind.grep', runGrep)
  );
}
function deactivate() {}
module.exports = { activate, deactivate };
