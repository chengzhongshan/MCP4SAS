'use strict';
// Bounded local discovery only: never reads credentials or starts a SAS session.
const fs = require('node:fs'), path = require('node:path'), os = require('node:os');
const core = require('./core');
const JARS = ['sas.rutil.jar', 'sas.rutil.nls.jar', 'sastpj.rutil.jar'];
function discoveryPaths(config, options = {}) {
  const platform = options.platform || process.platform, env = options.env || process.env;
  const home = options.home || os.homedir(), io = options.fs || fs;
  const p = platform === 'win32' ? path.win32 : path.posix;
  const exists = file => { try { return !!file && io.statSync(file).isFile(); } catch { return false; } };
  const dirs = dir => { try { return io.readdirSync(dir, { withFileTypes: true }).filter(d=>d.isDirectory()).slice(0,24).map(d=>p.join(dir,d.name)); } catch { return []; } };
  const onPath = name => (env.PATH || env.Path || '').split(platform === 'win32' ? ';' : ':').filter(Boolean).map(d=>p.join(d,name));
  const roots = [env.VIRTUAL_ENV, env.CONDA_PREFIX, ...['anaconda3','miniconda3','miniforge3','mambaforge'].map(d=>p.join(home,d))].filter(Boolean);
  try { roots.push(...io.readFileSync(p.join(home,'.conda','environments.txt'),'utf8').split(/\r?\n/).filter(Boolean).slice(0,24)); } catch { /* optional metadata */ }
  const python = [config.python, env.PIPELINE_PYTHON_BIN, p.join(config.repo,'.venv-pipeline','bin','python'), p.join(config.repo,'.venv-pipeline','Scripts','python.exe')];
  for (const root of roots) python.push(p.join(root,platform === 'win32' ? 'python.exe' : 'bin/python'));
  if (platform === 'win32') {
    for (const parent of [env.LOCALAPPDATA && p.join(env.LOCALAPPDATA,'Programs','Python'), env.ProgramFiles && p.join(env.ProgramFiles,'Python')].filter(Boolean)) for(const d of dirs(parent)) python.push(p.join(d,'python.exe'));
    python.push(...onPath('python.exe'),...onPath('python3.exe'));
  } else python.push(...onPath('python3'),...onPath('python'),'/usr/bin/python3','/opt/homebrew/bin/python3','/usr/local/bin/python3');
  const sas = [env.SAS_EXECUTABLE, env.SASPY_LOCAL_SAS_PATH, env.MCP4SAS_LOCAL_SAS_PATH];
  if(platform === 'win32') {
    for(const root of [env.SASROOT, p.join(env.ProgramFiles||'C:\\Program Files','SASHome','SASFoundation'),p.join(env['ProgramFiles(x86)']||'C:\\Program Files (x86)','SASHome','SASFoundation')].filter(Boolean)) {
      sas.push(p.join(root,'sas.exe'));for(const d of dirs(root))sas.push(p.join(d,'sas.exe'));
    }
  } else if(platform === 'linux') sas.push(...onPath('sas'),'/usr/local/SASHome/SASFoundation/9.4/sas','/opt/sasinside/SASHome/SASFoundation/9.4/bin/sas_u8','/opt/sas/SASHome/SASFoundation/9.4/sas');
  const jarDirs = [env.MCP4SAS_SASPY_IOM_DIR, p.join(home,'Downloads','SAS-ODA-JarFiles'),p.join(home,'Downloads','SAS-ODA-Jars'),p.join(home,'sas-iom-encryption-jars')].filter(Boolean);
  const unique = list => [...new Set(list.filter(Boolean).map(x=>p.normalize(x)))];
  const managed=p.normalize(p.join(config.repo,'.venv-pipeline','bin','python'));
  // Windows stat cannot follow Cygwin's Python symlink. Probe this bounded
  // installer-owned location through the selected Bash instead.
  return {python:unique(python).filter(x=>!/[\\/]Microsoft[\\/]WindowsApps[\\/]/i.test(x)&&(exists(x)||(platform==='win32'&&x===managed&&io.existsSync(p.dirname(x))))).slice(0,24),sas:platform==='darwin'?[]:unique(sas).filter(exists),jarDirs:unique(jarDirs).filter(d=>JARS.every(n=>exists(p.join(d,n))))};
}
const PROBE = String.raw`import sys, os, json, importlib.util
try:
 import saspy
 ready = True
except Exception:
 ready = False
spec = importlib.util.find_spec('saspy')
base = os.path.dirname(spec.origin) if spec and spec.origin else ''
jars = os.path.join(base, 'java', 'iomclient') if base else ''
print('MCP4SAS_DETECT_JSON=' + json.dumps({'python':sys.executable,'platform':sys.platform,'saspy':ready,'com':importlib.util.find_spec('win32com') is not None,'jar_directory':jars,'missing_jars':[n for n in ['sas.rutil.jar','sas.rutil.nls.jar','sastpj.rutil.jar'] if not os.path.isfile(os.path.join(jars,n))]}))
`;
function parseProbe(text) {
  const line = text.split(/\r?\n/).findLast(x=>x.startsWith('MCP4SAS_DETECT_JSON='));
  if(!line) throw Error('No Python discovery result');
  const r=JSON.parse(line.slice('MCP4SAS_DETECT_JSON='.length));
  if(typeof r.python!=='string'||typeof r.saspy!=='boolean')throw Error('Invalid Python discovery result');return r;
}
async function detect(config, options = {}) {
  const platform=options.platform||process.platform, env=options.env||process.env, io=options.fs||fs;
  const paths=discoveryPaths(config,options), run=options.run||core.run;
  if(platform==='win32' && !options.skipLauncher) {
    // The standard Python launcher also finds installations outside PATH.
    try { const text=await run('py.exe',['-0p'],{timeout:4000});for(const line of text.split(/\r?\n/)){const match=line.match(/([A-Za-z]:\\.*?python(?:3)?\.exe)\s*$/i);if(match&&io.existsSync(match[1])&&!paths.python.includes(match[1]))paths.python.push(match[1]);} } catch { /* optional launcher */ }
  }
  const python=[];let cursor=0;
  await Promise.all(Array.from({length:Math.min(4,paths.python.length)},async()=>{while(cursor<paths.python.length){const candidate=paths.python[cursor++];try{
    let command=candidate,args=['-c',PROBE];
    if(platform==='win32' && /[\\/]bin[\\/]python(?:3(?:\.\d+)?)?$/.test(candidate)) {
      command=path.win32.join(path.win32.dirname(config.perl),'bash.exe');
      const posix=await run(path.win32.join(path.win32.dirname(config.perl),'cygpath.exe'),['-u',candidate],{timeout:4000,env:core.cygwinEnvironment(config.perl,env)});
      args=['--noprofile','--norc','-c','exec "$@"','mcp4sas-python-probe',posix.trim(),'-c',PROBE];
    }
    const text=await run(command,args,{timeout:5000,env:platform==='win32'?core.cygwinEnvironment(config.perl,env):env});python.push({candidate,...parseProbe(text)});
  }catch{/* broken/stale interpreter is not advertised */}}}));
  python.sort((a,b)=>paths.python.indexOf(a.candidate)-paths.python.indexOf(b.candidate));
  const ready=python.filter(x=>x.saspy), native=python.filter(x=>platform==='win32'?x.platform==='win32':x.platform===platform);
  const oda=ready.find(x=>x.candidate===config.python)||ready[0];
  const local=paths.sas.length ? native.find(x=>x.saspy&&(platform!=='win32'||x.com||config.saspyCfgname==='winlocal')) : undefined;
  return {platform,python,oda,local,native:native[0],sas:paths.sas[0],jarDirectory:paths.jarDirs[0],needsLocalSupport:!!paths.sas.length&&!local};
}
function configuredTarget(config, found, kind) {
  const r={...config};
  if(kind==='local') {
    if(!found.local||!found.sas)throw Error('Local SAS support was not detected. Run Quick Setup to install the required Python support.');
    r.python=found.local.candidate;
    if(!/^(winlocal|winlocal_com|linuxlocal|local|stdio)$/.test(r.saspyCfgname||''))delete r.saspyCfgfile;
    r.saspyCfgname=found.platform==='win32'?(config.saspyCfgname==='winlocal'?'winlocal':'winlocal_com'):'linuxlocal';
    r.sasExecutable=found.sas;
  } else {
    if(!found.oda)throw Error('SASPy was not found. Run MCP4SAS: Quick Setup and choose Install MCP4SAS for this computer to install the required environment.');
    r.python=found.oda.platform==='cygwin'?found.oda.python:found.oda.candidate;r.saspyCfgname='oda';delete r.sasExecutable;
    if(config.saspyCfgname&&config.saspyCfgname!=='oda')delete r.saspyCfgfile;
  }
  return r;
}
module.exports={discoveryPaths,detect,parseProbe,configuredTarget,JARS};
