const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { hostExecutable } = require('./host-executable.cjs');

test('macOS host uses the bundle executable when the old Electron alias is absent', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'mcp4sas-app-'));
  const macos = path.join(root, 'Contents', 'MacOS');
  const historical = path.join(macos, 'Electron');
  const plist = path.join(root, 'Contents', 'Info.plist');
  fs.mkdirSync(macos, { recursive: true });
  fs.writeFileSync(path.join(macos, 'Code'), 'fixture');
  try {
    fs.writeFileSync(plist, '<key>CFBundleExecutable</key>\n<string>Code</string>');
    assert.equal(hostExecutable(historical, 'darwin'), path.join(macos, 'Code'));
    assert.equal(hostExecutable(historical, 'win32'), historical);
    fs.writeFileSync(plist, '<key>CFBundleExecutable</key><string>../outside</string>');
    assert.throws(() => hostExecutable(historical, 'darwin'), /Invalid VS Code/);
    fs.writeFileSync(historical, 'legacy fixture');
    assert.equal(hostExecutable(historical, 'darwin'), historical);
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});
