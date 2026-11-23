'use strict';
// Apply only connection selectors, never a copied process environment or login.
// VS Code scopes these mutations to new terminals in this workspace folder.
function apply(context, vscode, config) {
  const collection=context.environmentVariableCollection;
  if(!collection)return; // Minimal API fixtures do not create real terminals.
  collection.clear();
  const folders=vscode.workspace.workspaceFolders||[];
  for(const workspaceFolder of folders) {
    const scoped=collection.getScoped({workspaceFolder});scoped.clear();
    if(!config||!vscode.workspace.isTrusted||vscode.env.remoteName)continue;
    scoped.description='MCP4SAS selected SAS target: '+(config.saspyCfgname||'oda')+'. Open a new terminal after switching.';
    const selectors={SASPY_CFGNAME:config.saspyCfgname||'oda',SASPY_CONFIG_NAME:config.saspyCfgname||'oda',
      SASPY_CFGFILE:config.saspyCfgfile||'',PIPELINE_PYTHON_BIN:config.python||'',
      SAS_ODA_SESSION_PORT:config.sessionPort?String(config.sessionPort):'',SASPY_JAVA_WIN:config.java||''};
    for(const [name,value] of Object.entries(selectors))scoped.replace(name,value,{applyAtProcessCreation:true});
  }
}
module.exports={apply};
