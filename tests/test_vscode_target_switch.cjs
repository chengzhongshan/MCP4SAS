// Offline regression entry point; no SAS installation or account is required.
const cp=require('node:child_process'),path=require('node:path');
const directory=path.resolve(__dirname,'../integrations/vscode');
const result=cp.spawnSync(process.execPath,['--test','test/targets.test.js','test/relay-switch.test.js','test/setup.test.js'],{cwd:directory,stdio:'inherit',windowsHide:true});
process.exitCode=result.status??1;
