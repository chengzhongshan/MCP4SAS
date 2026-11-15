# Check tools, then check SAS

**Check Connection** starts a temporary backend and discovers its tools. It does not submit SAS.

Use **Copy SAS test prompt** and paste it into your selected assistant. For the standard `SASHELP.CLASS` table, the known ages, missing ages, minimum and maximum should be **19, 0, 11 and 16**.

Or run **MCP4SAS: Test Selected SAS** to submit this check directly without an
AI assistant. Click the SAS target in the status bar to switch between ODA and
detected local Windows/Linux SAS; open a new runtime terminal for manual commands.

Wait for the final job result and inspect the actual SAS log. Tool discovery alone does not prove your SAS login works.
