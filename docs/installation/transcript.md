## MCP4SAS: connect your AI assistant to SAS

Welcome! Let's install MCP4SAS in Visual Studio Code, connect to SAS, and see both GitHub Copilot and Codex run a SAS program. We'll start here, on the MCP4SAS GitHub homepage.

## Create your working folder

Start with a folder for your SAS programs. This is where the workspace installer will place the MCP4SAS scripts.

## Open the folder in VS Code

First, choose File, Open Folder in Visual Studio Code, and select the folder where you want to work. That's where the extension will install your MCP4SAS scripts. Make sure you have permission to save files there.

## Install the extension from VSIX

In the Extensions menu, choose Install from VSIX. Download the current zero point one point five build from the release link.

## Select the downloaded VSIX

Select the downloaded MCP4SAS VSIX file. This installs the editor extension; Quick Setup will prepare the runtime next.

## Open MCP4SAS Quick Setup

Press Control Shift P, type MCP4SAS, and choose Quick Setup from the command list.

## Install for this computer

Choose Install MCP4SAS for this computer. The workspace build installs the scripts directly in the folder you opened.

## Cygwin setup begins

On Windows, guided setup can download and install Cygwin for you. Let the official setup program finish.

## Cygwin downloads its packages

Setup downloads Cygwin packages from the configured mirror. Download speed depends on your connection.

## The runtime installer starts

The terminal now shows the MCP4SAS installer running and creating its Python environment. This is installation progress, not completion yet.

## Python and SASPy dependencies

Here the installer prepares Python dependencies, including SASPy. Keep this terminal open while setup runs.

## The SASPy profile is configured

The installer writes the SASPy profile for this runtime. Private account authentication is configured separately.

## Perl dependency checks

Next, setup checks the Perl modules needed by the runner and server. Wait for the build checks to finish.

## Perl dependencies continue

This capture shows another Perl dependency being built. A successful dependency check is only one part of the installation.

## The installation smoke checks

The local smoke checks verify Python imports, the Java classpath and Perl syntax. They do not establish an authenticated SAS session.

## Installation check passes

The terminal reports that the installation smoke check passed. The additional server instructions are available, but the extension manages its own backend.

## Get the encryption JARs directly from SAS

These three encryption JARs must be obtained from SAS. Open the official SAS download link shown here and in the description. Sign in with your SAS Profile if prompted, download the package, and extract the ZIP. Locate the three exact filenames on screen and put them directly in one folder outside your Git repository. Java installation alone doesn't supply them. MCP4SAS doesn't redistribute them. Next, select that folder using Configure SAS Encryption JARs.

## Configure SAS Encryption JARs

Back in the Command Palette, select MCP4SAS: Configure SAS Encryption JARs. First obtain the files from SAS, as just explained.

## Select your extracted JAR folder

Choose the folder where you extracted the three SAS encryption JARs. Select the folder itself, not the ZIP archive.

## JAR configuration completes

The JAR helper configures the installed SASPy profile. Restart an old assistant connection or SAS session after changing the classpath.

## Configure SAS ODA Login

Now choose MCP4SAS: Configure SAS ODA Login. This opens a private local terminal, rather than asking for credentials in chat.

## Enter your own SAS account

Enter your own SAS OnDemand account in the local prompt. Use the account details registered for your SAS service.

## Enter the password privately

Enter your password at the private terminal prompt. Password characters are hidden; never paste them into an AI conversation.

## The login is validated

The terminal reports successful connection validation. The helper saves credentials only after validating them against SAS.

## Check the terminal folder

The command prompt is in the Test MCP4SAS workspace. Relative program and data paths will be resolved from this folder.

## Use the Cygwin terminal profile

The Command Palette includes the Cygwin terminal-profile action. New terminals can use the selected Cygwin installation.

## Discover the Perl command options

The Perl submission runner is now available in the workspace. Its help output lists the supported options.

## Read the runner help

The command help includes connection checks, file submissions and file-transfer options. Use only the options needed for your task.

## Check access through your company network

This checks the real SAS connection. On a company network, a firewall may block SASPy even when the SAS website opens in your browser. SAS OnDemand uses outbound TCP port 8591. Ask your IT or information services team to allow access from this computer to the SAS ODA servers for your home region. A timeout can also have other causes, so check the reported error.

## The connection check succeeds

Here the runner confirms the ODA connection. You can now move on to submitting a small SAS program.

## Submit SAS code directly

Run the inline PROC PRINT example from the terminal. The command uses the configured connection without an AI request.

## The SAS job is running

The runner checks the source and submits the program. Wait for completion before treating the output as a result.

## The output files are returned

The job completed, and the runner reports where the HTML output and SAS log were saved.

## View the SAS PRINT output

The browser displays the SAS-generated teaching table. Inspect the returned output alongside the actual SAS log.

## Open a SAS program file

The code command opens test dot sas in Visual Studio Code. Opening a file does not save text you type afterward.

## Write and save your SAS code

Enter the procedure in test dot sas and press Control S. The Perl runner reads the saved file on disk.

## Submit the saved file

Use the file option with the exact saved filename. Check spelling and the terminal directory if the program cannot be found.

## Check the saved-file workflow

This capture is part of the saved-file workflow. Save the editor contents and confirm that the local file contains your SAS statements.

## Run test.sas from Cygwin

The command now submits the saved test dot sas file from the workspace. It uses the same ODA configuration.

## Wait for the file submission

The terminal shows the SAS connection and program submission in progress. Keep the complete log for troubleshooting.

## The file submission completes

The runner reports completion and the returned HTML and log locations. Successful startup alone would not establish this result.

## Inspect the returned SAS table

Open the generated HTML report and compare its contents with the procedure you submitted. This is actual SAS output.

## Copilot: ask to run SAS

First, let's use GitHub Copilot. The Chat tab is active, and the request asks Copilot to print the SAS teaching dataset through MCP4SAS.

## Copilot prepares the MCP4SAS call

The assistant is preparing the request. Its reasoning text is not yet evidence that SAS has executed the program.

## Copilot requests tool permission

The assistant requests access to the MCP4SAS tool. Review the action and allow it according to your own workspace policy.

## Copilot waits for the SAS result

The assistant checks the job status instead of assuming that a submitted job has finished.

## Copilot completes the SAS run

Copilot reports that the SAS program completed with exit code zero and no warnings. It provides a link to the returned SAS output.

## Copilot: locate the saved SAS output

The Explorer menu can reveal output files on disk. This is useful when you want to inspect or share a generated report.

## Copilot: find the report and log

The results directory contains the HTML report and diagnostic files. Retain the log when investigating an unexpected result.

## Copilot: open the returned results

The user asks the assistant to show the returned results. The assistant should read the actual files, not invent a table.

## Copilot displays the SAS table

Copilot now displays the returned SAS table. This completes the Copilot demonstration: the program was submitted, the output was saved, and the results can be inspected.

## Codex: ask to test the SAS program

Now switch to the Codex tab. Ask Codex to test the saved SAS program through MCP4SAS. The next screenshot shows Codex's completed run and links to its results.

## Codex completes the SAS run

Codex reports that the SAS program completed with exit code zero and no reported SAS errors or warnings. Open the HTML results and log to inspect them. Both Copilot and Codex have now demonstrated the SAS workflow.

## Codex: inspect the assistant settings

The final screenshot shows Codex's model and reasoning controls. Choose the settings available with your account; MCP4SAS supplies the SAS execution tools.

## SAS setup is detected automatically

Quick Setup now finds your Python and SAS software automatically. If SAS is installed on your computer, choose either SAS OnDemand or SAS installed on this computer. You don't need to browse for Python or choose a SASPy profile. To check again later, run MCP4SAS: Detect SAS Setup.

## Local SAS support, without searching for files

For local Windows SAS, setup finds native Python and the required packages. If support is missing, it creates a separate environment for you. Your SAS installation must still be licensed. Restart the assistant connection after changing where SAS runs, then ask for a small SAS test and check the returned log.

## Windows CMD alternative

As an alternative, run the included Windows command file from an extracted MCP4SAS repository. It installs the extension. Then open your workspace and use Quick Setup to install the runtime. The same JAR and account requirements apply.

## macOS: terminal installation

On a Mac, clone the repository, enter its folder, and run the Mac installer. Complete Xcode Command Line Tools or Homebrew setup when prompted. SAS OnDemand still requires your account and the SAS encryption JARs.

## Ubuntu: terminal installation

On Ubuntu, install Git if needed, clone the repository, and run the Ubuntu installer. Allow sudo to install dependencies, then configure your SAS account and the required encryption files.

## The same VS Code extension on all three systems

The same VSIX extension works on Windows, Mac and Ubuntu. Open your intended working folder, run Quick Setup, and select your assistant. Cygwin is only needed on Windows. Keep passwords private, save your SAS files, and verify the actual output and log. The links, commands and caption file accompany this video.
