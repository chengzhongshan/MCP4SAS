// Bounded software discovery only: no SAS execution or credential-file reads.
'use strict';
const fs=require('node:fs'),d=require('../integrations/vscode/src/detect');
if(!process.argv[2])throw Error('Usage: node tests/probe_vscode_sas_setup.cjs PATH_TO_RUNTIME_JSON');
d.detect(JSON.parse(fs.readFileSync(process.argv[2],'utf8'))).then(result=>console.log(JSON.stringify(result,null,2))).catch(e=>{console.error(e.message);process.exitCode=1;});
