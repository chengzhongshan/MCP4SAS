'use strict';
const {test}=require('node:test'),assert=require('node:assert/strict');
const profile=require('../src/local-profile'),detect=require('../src/detect');
test('new Windows local targets default to IOM; remembered COM remains explicit',()=>{
  const found={platform:'win32',local:{candidate:'python.exe'},sas:'C:\\SAS\\sas.exe'};
  assert.equal(detect.configuredTarget({saspyCfgname:'oda'},found,'local').saspyCfgname,'winlocal');
  assert.equal(detect.configuredTarget({saspyCfgname:'winlocal_com'},found,'local').saspyCfgname,'winlocal_com');
});
test('IOM profile derives native libraries and prefers the installed SAS Java',()=>{
  const config={saspyCfgname:'winlocal',sasExecutable:'C:\\Program Files\\SASHome\\SASFoundation\\9.4\\sas.exe',java:'C:\\OtherJava\\java.exe'};
  const source=profile.source(config,'win32',()=>true);
  assert.match(source,/SASPrivateJavaRuntimeEnvironment/);assert.match(source,/java.library.path/);
  assert.ok(!source.includes('iomhost'));assert.ok(!source.includes('provider'));
});
test('IOM profile uses detected Java when SAS private Java is absent',()=>{
  const source=profile.source({sasExecutable:'D:\\SAS\\9.4\\sas.exe',java:'C:\\Java\\java.exe'},'win32',()=>false);
  assert.ok(source.includes('C:\\\\Java\\\\java.exe'));
});
