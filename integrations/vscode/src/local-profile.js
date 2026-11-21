'use strict';
const fs = require('node:fs'), path = require('node:path');
function source(config, platform = process.platform, exists = fs.existsSync) {
  if (platform !== 'win32') return "SAS_config_names = ['linuxlocal']\nSAS_config_options = {'lock_down': False, 'prompt': False}\nlinuxlocal = {'saspath': " + JSON.stringify(config.sasExecutable) + ", 'encoding': 'utf-8'}\n";
  if (config.saspyCfgname === 'winlocal_com') return "SAS_config_names = ['winlocal_com']\nSAS_config_options = {'lock_down': False, 'prompt': False}\nwinlocal_com = {'provider': 'sas.iomprovider', 'encoding': 'windows-1252'}\n";
  const p = path.win32, sasRoot = p.dirname(config.sasExecutable);
  const native = p.join(sasRoot, 'core', 'sasext');
  const bundledJava = p.join(sasRoot, '..', '..', 'SASPrivateJavaRuntimeEnvironment', '9.4', 'jre', 'bin', 'java.exe');
  const java = exists(bundledJava) ? bundledJava : config.java || 'java';
  // Let SASPy build its own version-specific classpath. No remote host/port
  // is needed for local IOM. The native SSPI library belongs to installed SAS.
  return `import os\nSAS_config_names = ['winlocal']\nSAS_config_options = {'lock_down': False, 'prompt': False}\n_native = ${JSON.stringify(native)}\nos.environ['PATH'] = _native + os.pathsep + os.environ.get('PATH', '')\nwinlocal = {'java': ${JSON.stringify(java)}, 'javaparms': ['-Djava.library.path=' + _native], 'encoding': 'windows-1252'}\n`;
}
module.exports = {source};
