'use strict';
const {test}=require('node:test'),assert=require('node:assert/strict');
const {apply}=require('../src/terminal-target');
test('ODA/local/ODA replaces only connection selectors in each open folder',()=>{
 const folders=[{name:'one'},{name:'two'}],scopes=new Map(),global=new Map([['old','value']]);
 const collection={clear(){global.clear();},getScoped({workspaceFolder}){if(!scopes.has(workspaceFolder))scopes.set(workspaceFolder,new Map());const values=scopes.get(workspaceFolder);return {clear(){values.clear();},replace(key,value){values.set(key,value);}};}};
 const vscode={workspace:{workspaceFolders:folders,isTrusted:true},env:{}},context={environmentVariableCollection:collection};
 const oda={saspyCfgname:'oda',python:'/oda/python',saspyCfgfile:'/private/oda.py',sessionPort:41001,java:'/java',password:'DO_NOT_COPY',HOME:'/private/home',PATH:'/private/path'};
 const local={saspyCfgname:'winlocal',python:'C:/python.exe',saspyCfgfile:'C:/local.py',sessionPort:41002};
 for(const config of [oda,local,oda]) {
  apply(context,vscode,config);assert.equal(global.size,0);
  for(const values of scopes.values()) {
   assert.equal(values.get('SASPY_CFGNAME'),config.saspyCfgname);
   assert.equal(values.get('SASPY_CONFIG_NAME'),config.saspyCfgname);
   assert.equal(values.get('SASPY_CFGFILE'),config.saspyCfgfile);
   assert.equal(values.get('PIPELINE_PYTHON_BIN'),config.python);
   assert.equal(values.get('SAS_ODA_SESSION_PORT'),String(config.sessionPort));
   assert.equal(values.size,6);assert.equal(values.has('password'),false);assert.equal(values.has('PATH'),false);assert.equal(values.has('HOME'),false);
  }
 }
 apply(context,vscode,{saspyCfgname:'oda'});
 assert.equal(scopes.get(folders[0]).get('SASPY_CFGFILE'),'','clear an inherited local profile');
 for(const state of ['untrusted','remote','missing']) {
  vscode.workspace.isTrusted=state!=='untrusted';vscode.env.remoteName=state==='remote'?'ssh-remote':undefined;
  apply(context,vscode,state==='missing'?null:oda);
  for(const values of scopes.values())assert.equal(values.size,0);
 }
});
