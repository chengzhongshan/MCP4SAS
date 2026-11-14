'use strict';
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs'), os = require('node:os'), path = require('node:path');
const core = require('../src/core');
test('VS Code write probe is temporary and preserves existing project files', async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-write-'));
  try {
    fs.writeFileSync(path.join(dir, 'test.sas'), 'proc print; run;');
    await core.assertWritableProject(dir, undefined, { platform: 'native' });
    assert.deepEqual(fs.readdirSync(dir), ['test.sas']);
    assert.equal(fs.readFileSync(path.join(dir, 'test.sas'), 'utf8'), 'proc print; run;');
  } finally { fs.unlinkSync(path.join(dir, 'test.sas')); fs.rmdirSync(dir); }
});
test('Cygwin reads and writes the exact VS Code probe through cwd and literal arguments', async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), "mcp4sas Bob's project "));
  try {
    await core.assertWritableProject(dir, 'C:/selected/bin/perl.exe', { platform: 'win32', async runCommand(command, args, options) {
      assert.equal(command, path.join('C:/selected/bin', 'bash.exe'));
      assert.equal(options.cwd, dir);
      assert.equal(args[4], 'mcp4sas-write-check');
      assert.equal(fs.readFileSync(path.join(dir, args[5]), 'utf8'), args[6]);
      assert.ok(!args[3].includes(dir), 'project path is never shell source');
      fs.writeFileSync(path.join(dir, args[5]), 'MCP4SAS Cygwin write OK');
    } });
    assert.deepEqual(fs.readdirSync(dir), []);
  } finally { fs.rmdirSync(dir); }
});
test('VS Code permission failure explains how to choose a folder before running Cygwin', async () => {
  let ran = false;
  await assert.rejects(core.assertWritableProject(os.tmpdir(), 'C:/bin/perl.exe', { platform: 'win32',
    filesystem: { ...fs, writeFileSync() { throw new Error('EACCES'); } },
    async runCommand() { ran = true; }
  }), /File > Open Folder.*IT.*EACCES/);
  assert.equal(ran, false);
});
test('Cygwin denial or a different file mapping prevents success and removes the probe', async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-denied-'));
  try {
    for (const runCommand of [async () => { throw new Error('Permission denied'); }, async () => {}]) {
      await assert.rejects(core.assertWritableProject(dir, 'C:/bin/perl.exe', { platform: 'win32', runCommand }), /VS Code and Cygwin/);
      assert.deepEqual(fs.readdirSync(dir), []);
    }
  } finally { fs.rmdirSync(dir); }
});
