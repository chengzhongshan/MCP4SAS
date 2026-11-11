const fs = require('node:fs');
const path = require('node:path');

// test-electron 2.5.2 returns the historical Electron name on macOS.
// Current VS Code bundles declare their actual binary in Info.plist.
function hostExecutable(executable, platform = process.platform) {
  if (fs.existsSync(executable) || platform !== 'darwin') return executable;
  const macos = path.dirname(executable);
  const plist = fs.readFileSync(path.join(macos, '..', 'Info.plist'), 'utf8');
  const name = plist.match(/<key>CFBundleExecutable<\/key>\s*<string>([^<]+)<\/string>/)?.[1];
  if (!name || name !== path.basename(name) || name === '.' || name === '..') throw new Error('Invalid VS Code CFBundleExecutable in Info.plist.');
  const candidate = path.join(macos, name);
  if (!fs.existsSync(candidate)) throw new Error(`VS Code test executable not found: ${candidate}`);
  return candidate;
}
module.exports = { hostExecutable };
