# Start with Quick Setup

Choose **Use my existing MCP4SAS installation** or **Install MCP4SAS for this computer**.

If no folder is open, Quick Setup first offers **Choose Project Folder**.
Open a folder you own and confirm VS Code's trust prompt if shown. Setup
continues automatically after the folder opens. It does not install into an
unknown directory or require a manual restart.

Windows: the guided installer offers Cygwin before downloading MCP4SAS. Its
official progress window is visible. The setup checklist and notification
show elapsed time; downloads can take more than five minutes. Keep VS Code
and the installer open, and use **Show installation log** for details.

macOS and Ubuntu/Debian: the existing platform installer runs in a visible terminal.

You will also choose the folder containing your SAS project. That folder is where the server looks for relative files and a `Macros` subfolder.

Setup detects the required Python and SASPy environment automatically. If local SAS is found, choose SAS OnDemand or SAS installed on this computer. No Python/configuration file picker is required. Run **MCP4SAS: Detect SAS Setup** to rescan later.

For ODA, the setup page links to the official SAS encryption download. Sign
in there privately, download the archive, then choose **Select downloaded ZIP
or folder**. MCP4SAS finds the three JARs inside it. Configure ODA login in the
private terminal and finish with **Test selected SAS**.
