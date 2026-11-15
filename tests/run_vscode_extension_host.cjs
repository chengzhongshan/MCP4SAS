// Actual VS Code host; with --runtime, also performs real ODA/local/ODA checks.
// node tests/run_vscode_extension_host.cjs [--vscode PATH] [--runtime PATH --out JSON]
'use strict';
const cp=require('node:child_process'),fs=require('node:fs'),path=require('node:path');
const option=n=>{const i=process.argv.indexOf(n);return i<0?undefined:process.argv[i+1];};
const env={...process.env};
delete env.ELECTRON_RUN_AS_NODE;
if(option('--vscode'))env.VSCODE_EXECUTABLE=path.resolve(option('--vscode'));
const runtime=option('--runtime');
if(runtime){
 if(!option('--out'))throw Error('--runtime enables live SAS checks and requires --out JSON');
 env.MCP4SAS_LIVE_SWITCH_RUNTIME=path.resolve(runtime);
 env.MCP4SAS_LIVE_SWITCH_OUT=path.resolve(option('--out'));
 const config=JSON.parse(fs.readFileSync(runtime,'utf8'));
 if(process.platform==='win32')env.MCP4SAS_TEST_CYGWIN_PERL=config.perl;
}
const child=cp.spawn(process.execPath,[path.resolve(__dirname,'../integrations/vscode/test/run-host.cjs')],{env,stdio:'inherit',windowsHide:true});
child.on('error',e=>{console.error(e.message);process.exitCode=1;});
child.on('exit',code=>{process.exitCode=code??1;});
