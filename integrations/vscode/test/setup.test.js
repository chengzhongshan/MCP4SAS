'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const vm = require('node:vm');
const { createRequire } = require('node:module');
const core = require('../src/core');

test('Quick Setup saves a portable Cygwin runtime and connects Copilot after installation', async () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-portable-'));
  const extensionPath = path.resolve(__dirname, '..');
  const portable = path.join(root, 'portable Cygwin', 'bin', 'perl.exe');
  const java = path.join(root, 'Java', 'bin', 'java.exe');
  const project = path.join(root, 'SAS project');
  const storage = path.join(root, 'storage');
  for (const file of [portable, java, path.join(path.dirname(portable), 'cygpath.exe')]) {
    fs.mkdirSync(path.dirname(file), { recursive: true }); fs.writeFileSync(file, 'fixture');
  }
  fs.mkdirSync(project);
  const commands = new Map(), states = new Map(), errors = [], tasks = [];
  const choices = ['Install MCP4SAS for this computer', 'Choose an existing Cygwin Perl', [{ label: 'GitHub Copilot' }]];
  const dialogs = [portable, project];
  let onTaskEnd;
  const disposable = () => ({ dispose() {} });
  const vscode = {
    workspace: { isTrusted: true }, env: {},
    Uri: { file: fsPath => ({ fsPath }) },
    ProgressLocation: { Notification: 1 }, TaskScope: { Global: 1 }, TaskRevealKind: {}, TaskPanelKind: {},
    EventEmitter: class { event() {} fire() {} dispose() {} },
    ShellExecution: class { constructor(command, args, options) { Object.assign(this, { command, args, options }); } },
    Task: class { constructor(definition, scope, name, source, execution) { Object.assign(this, { definition, execution }); } },
    commands: { registerCommand(id, fn) { commands.set(id, fn); return disposable(); } },
    lm: { registerMcpServerDefinitionProvider: disposable },
    window: {
      createOutputChannel: () => ({ appendLine() {}, show() {}, dispose() {} }),
      showQuickPick: async () => choices.shift(),
      showOpenDialog: async () => [{ fsPath: dialogs.shift() }],
      withProgress: async (options, fn) => fn(),
      showInformationMessage() {}, showErrorMessage: message => errors.push(message)
    },
    tasks: {
      onDidEndTaskProcess(fn) { onTaskEnd = fn; return disposable(); },
      async executeTask(task) { tasks.push(task); queueMicrotask(() => onTaskEnd({ execution: { task }, exitCode: 0 })); }
    }
  };
  const mockedCore = {
    ...core,
    async run(command, args) {
      assert.equal(command, path.join(path.dirname(portable), 'git.exe'));
      assert.equal(args[0], 'clone');
      const repo = args.at(-1);
      for (const file of ['server.pl', 'MCPDeps/SAS_ODA_Runner.pm', 'install/common.sh']) {
        const target = path.join(repo, file); fs.mkdirSync(path.dirname(target), { recursive: true }); fs.writeFileSync(target, 'fixture');
      }
      return '';
    },
    async toPosix(value, perl) { assert.equal(perl, portable); return value; }
  };
  const realRequire = createRequire(path.join(extensionPath, 'src', 'extension.js'));
  const module = { exports: {} };
  try {
    vm.runInNewContext(fs.readFileSync(path.join(extensionPath, 'src', 'extension.js'), 'utf8'), {
      module, process: { platform: 'win32', execPath: process.execPath, env: { LOCALAPPDATA: root, ProgramFiles: root, SASPY_JAVA_WIN: java } },
      require(name) {
        if (name === 'vscode') return vscode;
        if (name === './core') return mockedCore;
        if (name === 'node:fs') return { ...fs, existsSync(file) { return String(file).startsWith(root) && fs.existsSync(file); } };
        return realRequire(name);
      }
    });
    module.exports.activate({ extensionPath, globalStorageUri: { fsPath: storage }, subscriptions: [], globalState: { get: key => states.get(key), async update(key, value) { states.set(key, value); } } });
    await commands.get('mcp4sas.setup')();
    assert.deepEqual(errors, []);
    const saved = JSON.parse(fs.readFileSync(path.join(storage, 'runtime.json'), 'utf8'));
    assert.equal(saved.perl, portable);
    assert.equal(saved.cwd, project);
    assert.equal(saved.java, java);
    assert.equal(tasks[0].execution.command, path.join(path.dirname(portable), 'bash.exe'));
    assert.equal(states.get('copilotEnabled'), true);
    assert.ok(fs.existsSync(path.join(storage, 'relay.js')));
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});
