'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const c = require('../src/core');
test('Cygwin setup selects its own DLL directory and retains certificate settings', () => {
  const base = { Path: 'C:/other-cygwin/bin;C:/Windows', HTTPS_PROXY: 'proxy', GIT_SSL_CAINFO: 'custom.pem' };
  const env = c.cygwinEnvironment('/selected/bin/perl.exe', base);
  assert.equal(env.PATH, '/selected/bin;'+base.Path);
  assert.equal(env.Path, undefined);
  assert.equal(env.GIT_SSL_CAINFO, 'custom.pem');
  assert.equal(env.HTTPS_PROXY, 'proxy');
  assert.equal(base.Path, 'C:/other-cygwin/bin;C:/Windows');
});
const launch = c.launcher('C:\\A folder\\runtime.json', 'C:\\A folder\\relay.js', 'C:\\Code\\Code.exe');
test('installation retains manually selected portable Perl when discovery cannot find it', () => {
  assert.equal(c.installedPerl(null, '/portable/bin/perl.exe'), '/portable/bin/perl.exe');
  assert.equal(c.installedPerl('/new/brew/perl', '/usr/bin/perl'), '/new/brew/perl');
  assert.throws(() => c.installedPerl(null, null), /Perl was not found/);
});
test('discovery handles initialization errors immediately and rejects malformed tool lists', () => {
  assert.throws(() => c.discoveryReply({ id: 1, error: { message: 'Perl dependency missing' } }), /Perl dependency missing/);
  assert.throws(() => c.discoveryReply({ id: 2, error: { message: 'Server unavailable' } }), /Server unavailable/);
  assert.throws(() => c.discoveryReply({ id: 1 }), /invalid MCP initialize/);
  assert.throws(() => c.discoveryReply({ id: 2, result: {} }), /invalid MCP tool list/);
  assert.deepEqual(c.discoveryReply({ id: 1, result: {} }), { initialize: true });
  assert.deepEqual(c.discoveryReply({ id: 2, result: { tools: [] } }), { tools: [] });
  assert.equal(c.discoveryReply({ method: 'notifications/message' }), null);
});
test('platform installers select the actual repository entry points', () => {
  for (const p of ['win32', 'linux', 'darwin']) assert.ok(fs.existsSync(path.join(__dirname, '../../..', 'install', c.platformInstaller(p))));
  assert.throws(() => c.platformInstaller('freebsd'));
});
test('Codex paths, Unicode and backslashes survive TOML', () => {
  const l = { ...launch, args: [...launch.args, '/tmp/张/π'] };
  const parsed = require('@iarna/toml').parse(c.mergeCodex('', l));
  assert.deepEqual(parsed.mcp_servers.mcp4sas_vscode.args, l.args);
  assert.equal(parsed.mcp_servers.mcp4sas_vscode.command, l.command);
});
test('unrelated comments, tables and server configuration are retained byte for byte', () => {
  const original = '# my preferences\nmodel = "something"\n[mcp_servers.existing]\ncommand="other"\n[projects."/x"]\ntrust_level="trusted"\n';
  assert.ok(c.mergeCodex(original, launch).startsWith(original));
});
test('Connect is idempotent and can update only its managed launcher', () => {
  const once = c.mergeCodex('', launch);
  assert.equal(c.mergeCodex(once, launch), once);
  const changed = c.mergeCodex(once + '\n[tools]\nweb_search=true\n', { ...launch, command: '/new/node' });
  assert.equal(require('@iarna/toml').parse(changed).tools.web_search, true);
});
test('unmanaged plain, quoted, dotted, inline or duplicate entries are refused', () => {
  for (const text of ['[mcp_servers.mcp4sas_vscode]\ncommand="mine"', '[mcp_servers."mcp4sas_vscode"]\ncommand="mine"', '[mcp_servers]\nmcp4sas_vscode.command="mine"', 'mcp_servers={mcp4sas_vscode={command="mine"}}', '[mcp_servers.x]\ncommand="x"\ncommand="y"']) assert.throws(() => c.mergeCodex(text, launch));
});
test('invalid TOML and incomplete managed blocks never get repaired silently', () => {
  for (const text of ['model="unterminated', c.BEGIN + '\n', c.END, c.BEGIN + '\n' + c.BEGIN + '\n' + c.END]) assert.throws(() => c.mergeCodex(text, launch));
});
test('comments and settings added inside managed block are not lost', () => {
  const modified = c.mergeCodex('', launch).replace('tool_timeout_sec = 180', 'tool_timeout_sec = 180\ncustom = "mine"');
  assert.throws(() => c.mergeCodex(modified, launch));
});
test('atomic Codex write backs up changed originals, leaves idempotent files alone', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-config-'));
  try {
    const file = path.join(dir, 'config.toml'); fs.writeFileSync(file, '# preserve\n');
    c.writeCodex(file, launch); const files = fs.readdirSync(dir);
    assert.equal(files.filter(n => n.endsWith('.bak')).length, 1);
    assert.equal(fs.readFileSync(path.join(dir, files.find(n => n.endsWith('.bak'))), 'utf8'), '# preserve\n');
    c.writeCodex(file, launch); assert.deepEqual(fs.readdirSync(dir), files);
  } finally { fs.rmSync(dir, { recursive: true, force: true }); }
});
test('invalid installations fail before configuration', () => {
  assert.throws(() => c.assertRepo(os.tmpdir()));
  c.assertRepo(path.join(__dirname, '../../..'));
  const partial = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-incomplete-'));
  try {
    for (const file of ['server.pl', 'MCPDeps/SAS_ODA_Runner.pm', 'install/common.sh']) {
      fs.mkdirSync(path.dirname(path.join(partial, file)), { recursive: true });
      fs.writeFileSync(path.join(partial, file), 'fixture');
    }
    assert.throws(() => c.assertRepo(partial), /missing run_sas_codes_or_files_in_ODA\.pl/);
  } finally { fs.rmSync(partial, { recursive: true, force: true }); }
});
test('Windows EPERM cleanup neither fails installation nor masks its original error', async () => {
  const stage = path.join(os.tmpdir(), 'mcp4sas-source-test-locked');
  const warnings = [];
  const locked = async (p, options) => {
    assert.equal(p, path.resolve(stage));
    assert.equal(options.maxRetries, 5);
    assert.equal(options.retryDelay, 200);
    throw Object.assign(new Error('access denied'), { code: 'EPERM' });
  };
  assert.equal(await c.cleanupStaging(stage, x => warnings.push(x), locked), false);
  assert.match(warnings[0], /EPERM/);
  const original = new Error('Source-file conflict');
  await assert.rejects(async () => { try { throw original; } finally { await c.cleanupStaging(stage, () => {}, locked); } }, error => error === original);
  let removed = false;
  assert.equal(await c.cleanupStaging(path.join(os.tmpdir(), 'unrelated'), () => {}, async () => { removed = true; }), false);
  assert.equal(removed, false, 'unrelated paths are never removed');
});
test('workspace install preserves user files and Git metadata and checks conflicts before writing', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-workspace-'));
  try {
    const source = path.join(root, 'source'), target = path.join(root, 'project');
    for (const file of ['server.pl', 'run_sas_codes_or_files_in_ODA.pl', 'MCPDeps/SAS_ODA_Runner.pm', 'install/common.sh', '.git/config']) {
      fs.mkdirSync(path.dirname(path.join(source, file)), { recursive: true });
      fs.writeFileSync(path.join(source, file), file);
    }
    fs.mkdirSync(path.join(target, '.git'), { recursive: true });
    fs.writeFileSync(path.join(target, '.git/config'), 'user git');
    fs.writeFileSync(path.join(target, 'analysis.sas'), 'user analysis');
    fs.writeFileSync(path.join(target, 'server.pl'), 'conflicting user file');
    assert.throws(() => c.installSourceFiles(source, target), /would overwrite/);
    assert.equal(fs.existsSync(path.join(target, 'install')), false, 'conflict check precedes all writes');
    fs.unlinkSync(path.join(target, 'server.pl'));
    c.installSourceFiles(source, target);
    c.installSourceFiles(source, target);
    c.assertRepo(target);
    assert.equal(fs.readFileSync(path.join(target, '.git/config'), 'utf8'), 'user git');
    assert.equal(fs.readFileSync(path.join(target, 'analysis.sas'), 'utf8'), 'user analysis');
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});
test('shell quoting treats spaces, apostrophes and shell expansions literally', () => {
  assert.equal(c.shellQuote("a'b $(test)"), "'a'\\''b $(test)'");
});

test('saved SAS targets reach the runner without mutating the inherited environment', () => {
  const inherited = { PATH: '/original', SASPY_CFGNAME: 'oda', HTTPS_PROXY: 'existing-proxy' };
  for (const saspyCfgname of ['oda', 'winlocal', 'winlocal_com', 'linuxlocal', 'remote_custom']) {
    const env = c.connectionEnvironment({ saspyCfgname, saspyCfgfile: '/private/config.py', python: '/chosen/python', sessionPort: 43210 }, inherited);
    assert.equal(env.SASPY_CFGNAME, saspyCfgname);
    assert.equal(env.SASPY_CFGFILE, '/private/config.py');
    assert.equal(env.PIPELINE_PYTHON_BIN, '/chosen/python');
    assert.equal(env.SAS_ODA_SESSION_PORT, '43210');
    assert.equal(env.HTTPS_PROXY, inherited.HTTPS_PROXY);
  }
  assert.equal(inherited.SASPY_CFGNAME, 'oda');
  assert.equal(inherited.SASPY_CFGFILE, undefined);
});
