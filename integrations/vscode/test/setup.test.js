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
  for (const file of [portable, java, path.join(path.dirname(portable), 'cygpath.exe'), path.join(path.dirname(portable), 'bash.exe')]) {
    fs.mkdirSync(path.dirname(file), { recursive: true }); fs.writeFileSync(file, 'fixture');
  }
  fs.mkdirSync(project);
  const commands = new Map(), states = new Map(), errors = [], tasks = [];
  const settings = new Map([['profiles.windows', { 'My existing shell': { path: 'original.exe' } }]]);
  let configureTerminal = true;
  const choices = ['Install MCP4SAS for this computer', 'Choose an existing Cygwin Perl', [{ label: 'GitHub Copilot' }]];
  const dialogs = [portable, project];
  let onTaskEnd;
  const disposable = () => ({ dispose() {} });
  const vscode = {
    workspace: { isTrusted: true, getConfiguration(section) {
      if (section === 'mcp4sas') return { get: () => configureTerminal };
      return { inspect: key => ({ globalValue: settings.get(key) }), async update(key, value) { settings.set(key, value); } };
    } }, env: {}, ConfigurationTarget: { Global: 1 },
    Uri: { file: fsPath => ({ fsPath }) },
    ProgressLocation: { Notification: 1 }, TaskScope: { Global: 1 }, TaskRevealKind: {}, TaskPanelKind: {},
    EventEmitter: class { event() {} fire() {} dispose() {} },
    ShellExecution: class { constructor() { throw new Error('Installer must not use the default terminal shell'); } },
    ProcessExecution: class { constructor(command, args, options) { Object.assign(this, { command, args, options }); } },
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
    async runtimeEnvironment() { return { HOME: '/selected/private-home', PIPELINE_PYTHON_BIN: 'selected-python' }; },
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
    const api = await module.exports.activate({ extensionPath, globalStorageUri: { fsPath: storage }, subscriptions: [], globalState: { get: key => states.get(key), async update(key, value) { states.set(key, value); } } });
    await commands.get('mcp4sas.setup')();
    assert.deepEqual(errors, []);
    const saved = JSON.parse(fs.readFileSync(path.join(storage, 'runtime.json'), 'utf8'));
    assert.equal(saved.perl, portable);
    assert.equal(saved.cwd, project);
    assert.equal(saved.java, java);
    assert.equal(tasks[0].execution.command, path.join(path.dirname(portable), 'bash.exe'));
    assert.ok(tasks[0].execution instanceof vscode.ProcessExecution);
    assert.deepEqual(Array.from(tasks[0].execution.args).slice(0, 2), ['--noprofile', '--norc']);
    assert.equal(states.get('copilotEnabled'), true);
    assert.ok(fs.existsSync(path.join(storage, 'relay.js')));
    assert.equal(settings.get('defaultProfile.windows'), 'MCP4SAS Cygwin');
    const profile = settings.get('profiles.windows')['MCP4SAS Cygwin'];
    assert.equal(profile.path, path.join(path.dirname(portable), 'bash.exe'));
    assert.equal(Array.from(profile.args).join(' '), '--login -i');
    assert.equal(profile.env.CHERE_INVOKING, '1');
    assert.equal(settings.get('profiles.windows')['My existing shell'].path, 'original.exe');
    settings.set('defaultProfile.windows', 'My existing shell');
    await api.configureCygwinTerminal(portable);
    assert.equal(settings.get('defaultProfile.windows'), 'My existing shell', 'later user preference is retained');
    await commands.get('mcp4sas.cygwinTerminal')();
    assert.equal(settings.get('defaultProfile.windows'), 'MCP4SAS Cygwin');
    configureTerminal = false;
    settings.set('defaultProfile.windows', 'My existing shell');
    states.delete('cygwinTerminalConfigured');
    await api.configureCygwinTerminal(portable);
    assert.equal(settings.get('defaultProfile.windows'), 'My existing shell', 'opt out is respected');
    await commands.get('mcp4sas.configureLogin')();
    assert.equal(tasks.at(-1).execution.command, portable);
    assert.equal(tasks.at(-1).execution.options.env.HOME, '/selected/private-home');
    assert.equal(tasks.at(-1).execution.options.env.SASPY_CFGNAME, 'oda');
    assert.ok(tasks.at(-1).execution.args.includes('--prompt-sas-oda-auth'));
    assert.ok(!tasks.at(-1).execution.args.includes('--sas-oda-password'));
    const jars = path.join(root, 'SAS JAR files'); fs.mkdirSync(jars);
    dialogs.push(jars);
    const beforeTasks = tasks.length;
    await commands.get('mcp4sas.configureJars')();
    assert.equal(tasks.length, beforeTasks, 'missing JARs do not run the installer');
    assert.match(errors.at(-1), /sas\.rutil\.jar/);
    assert.match(errors.at(-1), /pid=2494/);
    for (const name of ['sas.rutil.jar', 'sas.rutil.nls.jar', 'sastpj.rutil.jar']) fs.writeFileSync(path.join(jars, name), 'fixture');
    dialogs.push(jars);
    await commands.get('mcp4sas.configureJars')();
    assert.equal(tasks.length, beforeTasks + 1);
    assert.equal(tasks.at(-1).execution.options.env.MCP4SAS_SASPY_IOM_DIR, jars);
    assert.match(tasks.at(-1).execution.args.at(-1), /install_saspy_iom_jars\.sh$/);
    vscode.env.remoteName = 'ssh-remote';
    await api.configureCygwinTerminal(portable, true);
    assert.equal(settings.get('defaultProfile.windows'), 'My existing shell', 'remote settings are untouched');
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});
