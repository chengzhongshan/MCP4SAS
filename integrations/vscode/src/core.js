'use strict';
const fs = require('node:fs');
const path = require('node:path');
const cp = require('node:child_process');
const BEGIN = '# BEGIN MCP4SAS VS CODE (managed)';
const END = '# END MCP4SAS VS CODE (managed)';
function installSourceFiles(source, target) {
  assertRepo(source);
  const files = [];
  function walk(dir, relative = '') {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      if (!relative && entry.name === '.git') continue;
      const rel = path.join(relative, entry.name);
      if (entry.isDirectory()) walk(path.join(source, rel), rel);
      else if (entry.isFile()) files.push(rel);
      else throw new Error(`Unsupported source entry: ${rel}`);
    }
  }
  walk(source);
  for (const rel of files) {
    const dest = path.join(target, rel);
    let parent = path.dirname(dest);
    while (parent !== target && parent.startsWith(target + path.sep)) {
      if (fs.existsSync(parent) && (!fs.lstatSync(parent).isDirectory() || fs.lstatSync(parent).isSymbolicLink())) throw new Error(`Installation conflicts with existing path: ${parent}`);
      parent = path.dirname(parent);
    }
    if (fs.existsSync(dest) && (!fs.lstatSync(dest).isFile() || fs.lstatSync(dest).isSymbolicLink() || !fs.readFileSync(dest).equals(fs.readFileSync(path.join(source, rel))))) throw new Error(`Installation would overwrite ${dest}. Keep your file and use another open folder, or choose an existing MCP4SAS installation.`);
  }
  for (const rel of files) {
    const dest = path.join(target, rel);
    if (!fs.existsSync(dest)) { fs.mkdirSync(path.dirname(dest), { recursive: true }); fs.copyFileSync(path.join(source, rel), dest, fs.constants.COPYFILE_EXCL); }
  }
  assertRepo(target);
}

function run(command, args, options = {}) {
  return new Promise((resolve, reject) => {
    cp.execFile(command, args, { windowsHide: true, maxBuffer: 2 * 1024 * 1024, ...options }, (error, stdout, stderr) => {
      if (error) { error.message = `${path.basename(command)} failed (exit ${error.code}). ${stderr || stdout}`; reject(error); }
      else resolve(stdout.trim());
    });
  });
}
function platformInstaller(platform) {
  if (platform === 'win32') return 'install_cygwin.sh';
  if (platform === 'darwin') return 'install_macos.sh';
  if (platform === 'linux') return 'install_ubuntu.sh';
  throw new Error('Supported desktop hosts: Windows/Cygwin, macOS, Ubuntu/Debian Linux.');
}
function cygwinEnvironment(perl, base = process.env) {
  const env = { ...base };
  const key = Object.keys(env).find(k => k.toLowerCase() === 'path') || 'PATH';
  const inherited = env[key] || '';
  for (const k of Object.keys(env)) if (k.toLowerCase() === 'path') delete env[k];
  env.PATH = path.dirname(perl) + (inherited ? ';' + inherited : '');
  return env;
}
function installedPerl(detected, selected) {
  if (detected || selected) return detected || selected;
  throw new Error('Perl was not found after installation. Choose the Perl executable used by MCP4SAS and retry.');
}
function discoveryReply(message) {
  if (message.id !== 1 && message.id !== 2) return null;
  if (message.error) throw new Error(message.error.message || 'MCP discovery failed. Inspect the MCP4SAS output.');
  if (message.id === 1) {
    if (!message.result || typeof message.result !== 'object') throw new Error('Backend returned an invalid MCP initialize response.');
    return { initialize: true };
  }
  if (!Array.isArray(message.result?.tools)) throw new Error('Backend returned an invalid MCP tool list.');
  return { tools: message.result.tools };
}
function assertRepo(repo) {
  for (const file of ['server.pl', 'run_sas_codes_or_files_in_ODA.pl', 'MCPDeps/SAS_ODA_Runner.pm', 'install/common.sh']) {
    if (!fs.existsSync(path.join(repo, file))) throw new Error(`Not an MCP4SAS installation: missing ${file}`);
  }
}
function shellQuote(value) { return "'" + value.replace(/'/g, "'\\''") + "'"; }
function launcher(config, relay, executable) {
  return { command: executable, args: [relay, '--config', config], env: { ELECTRON_RUN_AS_NODE: '1' } };
}
function mergeCodex(text, launch) {
  // Preserve every byte outside our bounded block. Refuse ambiguous/manual collisions.
  const toml = require('@iarna/toml');
  const before = toml.parse(text);
  if (/^\s*\[\[/.test(text)) throw new Error('Unsupported Codex configuration; add this server manually using the guide.');
  const starts = text.split(BEGIN).length - 1, ends = text.split(END).length - 1;
  if (starts !== ends || starts > 1) throw new Error('Malformed MCP4SAS managed block; configuration left unchanged.');
  let outside = text;
  let from, to;
  if (starts) {
    from = text.indexOf(BEGIN); to = text.indexOf(END) + END.length;
    if (!/^\s*$/.test(text.slice(from + BEGIN.length, text.indexOf(END)).replace(/^\s*(?:#.*|\[mcp_servers\.mcp4sas_vscode\]|(?:command|args|env|startup_timeout_sec|tool_timeout_sec)\s*=.*)\r?$/gm, ''))) {
      throw new Error('Unrecognized content in managed block; configuration left unchanged.');
    }
    outside = text.slice(0, from) + text.slice(to);
  }
  if (/^\s*\[\s*mcp_servers\s*\.\s*["']?mcp4sas_vscode(?:["']?\s*[.\]])/m.test(outside) || /^\s*(?:mcp_servers|["']mcp_servers["'])\s*=/m.test(outside)) {
    throw new Error('An existing mcp4sas_vscode server or inline MCP table needs manual review; configuration left unchanged.');
  }
  const q = JSON.stringify;
  const block = `${BEGIN}\n[mcp_servers.mcp4sas_vscode]\ncommand = ${q(launch.command)}\nargs = ${q(launch.args)}\nenv = { ELECTRON_RUN_AS_NODE = "1" }\nstartup_timeout_sec = 60\ntool_timeout_sec = 180\n${END}`;
  if (!starts && before.mcp_servers?.mcp4sas_vscode) throw new Error('An existing mcp4sas_vscode entry needs manual review; configuration left unchanged.');
  const result = starts ? text.slice(0, from) + block + text.slice(to) : text + (text && !text.endsWith('\n') ? '\n' : '') + '\n' + block + '\n';
  const after = toml.parse(result);
  if (before.mcp_servers) { delete before.mcp_servers.mcp4sas_vscode; if (!Object.keys(before.mcp_servers).length) delete before.mcp_servers; }
  if (after.mcp_servers) { delete after.mcp_servers.mcp4sas_vscode; if (!Object.keys(after.mcp_servers).length) delete after.mcp_servers; }
  if (!require('node:util').isDeepStrictEqual(before, after)) throw new Error('Configuration meaning would change; file left unchanged.');
  return result;
}
function writePrivate(file, contents) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const temporary = `${file}.tmp-${process.pid}`;
  fs.writeFileSync(temporary, contents, { mode: 0o600 });
  fs.renameSync(temporary, file);
}
function writeCodex(file, launch) {
  const original = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : '';
  const changed = mergeCodex(original, launch);
  if (changed === original) return;
  if (original) fs.copyFileSync(file, `${file}.mcp4sas-${Date.now()}.bak`, fs.constants.COPYFILE_EXCL);
  writePrivate(file, changed);
}
async function toPosix(native, perl) {
  if (process.platform !== 'win32') return native;
  return run(path.join(path.dirname(perl), 'cygpath.exe'), ['-u', native], { env: cygwinEnvironment(perl) });
}
async function runtimeEnvironment(config) {
  const env = { ...process.env, OPEN_RESULT: '0', SAS_ODA_AUTOLOAD_MACROS: '0' };
  if (config.java) env.SASPY_JAVA_WIN = config.java;
  if (process.platform === 'win32') {
    const bash = path.join(path.dirname(config.perl), 'bash.exe');
    const values = await run(bash, ['--noprofile', '--norc', '-c', 'printf "%s\\n" "$HOME"; printf "%s\\n" "$PATH"'], { env: cygwinEnvironment(config.perl) });
    const [home, ...rest] = values.split(/\r?\n/);
    if (home) env.HOME = home;
    env.PATH = path.dirname(config.perl).replace(/\\/g, '/') + ':' + rest.join('\n');
  }
  return env;
}
module.exports = { run, platformInstaller, installSourceFiles, cygwinEnvironment, installedPerl, discoveryReply, assertRepo, shellQuote, launcher, mergeCodex, writeCodex, writePrivate, toPosix, runtimeEnvironment, BEGIN, END };
