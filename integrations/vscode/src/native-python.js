'use strict';
const fs = require('node:fs'), path = require('node:path');
const PROBE = "import sys, struct, venv, ensurepip, json; print(json.dumps({'platform':sys.platform,'version':list(sys.version_info[:2]),'bits':struct.calcsize('P')*8}))";
async function usable(executable, run, platform) {
  try {
    const result = JSON.parse((await run(executable, ['-I', '-c', PROBE], {timeout:15000})).trim());
    return result.platform === platform && result.version[0] === 3 && result.version[1] >= 10 && result.version[1] <= 13 && (platform !== 'win32' || result.bits === 64);
  } catch { return false; }
}
async function ensure(options) {
  const {storage, config, found, run, task, detect, log = () => {}, platform = process.platform} = options;
  const root = path.resolve(storage), envDir = path.join(root, 'native-saspy');
  const executable = path.join(envDir, platform === 'win32' ? 'Scripts/python.exe' : 'bin/python');
  let healthy = await usable(executable, run, platform);
  if (!healthy) {
    const candidates = [...new Set([found.native?.candidate, ...(found.python || []).filter(p => p.platform === platform).map(p => p.candidate)].filter(Boolean))];
    let python;
    for (const candidate of candidates) {
      // Never rebuild a venv from its own broken interpreter.
      if (path.resolve(candidate).startsWith(envDir + path.sep)) continue;
      if (await usable(candidate, run, platform)) { python = candidate; break; }
    }
    if (!python && platform === 'win32') {
      const target = path.join(root, 'python-runtime');
      python = path.join(target, 'python.exe');
      if (!await usable(python, run, platform)) {
        log('Installing native Windows Python for this user; Anaconda is not required.');
        await task('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', path.join(__dirname, 'install-native-python.ps1'), '-TargetDirectory', target], config.repo);
        if (!await usable(python, run, platform)) throw Error('Native Python installation did not produce a working 64-bit Python. Inspect the installer terminal and retry Detect SAS Setup.');
      }
    }
    if (!python) throw Error('Local SAS needs Python 3.10–3.13 with venv and ensurepip. Install the platform Python prerequisites and retry Detect SAS Setup.');
    if (fs.existsSync(envDir)) {
      // Only rename the exact managed directory, never an external environment.
      if (fs.lstatSync(envDir).isSymbolicLink() || path.dirname(fs.realpathSync(envDir)) !== fs.realpathSync(root)) throw Error('Refusing to replace a linked native-saspy environment. Restore its Python or select another environment.');
      const backup = envDir + '.backup-' + Date.now();
      fs.renameSync(envDir, backup);
      log('Retained the broken SASPy environment at ' + backup);
    }
    await task(python, ['-m', 'venv', envDir], config.repo);
    if (!await usable(executable, run, platform)) throw Error('The new native SASPy environment cannot run Python. Inspect the installer terminal.');
  }
  await task(executable, ['-I', '-m', 'pip', 'install', 'saspy', ...(platform === 'win32' ? ['pywin32'] : [])], config.repo);
  await run(executable, ['-I', '-c', 'import saspy' + (platform === 'win32' ? ', win32com.client' : '')], {timeout:15000});
  const detected = await detect({...config, python:executable});
  if (!detected.local) throw Error('Python dependencies installed, but local SAS support was not detected. Inspect MCP4SAS Output.');
  return detected;
}
module.exports = {ensure, usable, PROBE};
