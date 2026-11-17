# First-run setup improvements — 16 November 2026

The 0.1.5 extension retains its existing commands and SAS targets. The change
addresses three points where a first-time user could lose track of setup.

## Folder and trust before installation

Quick Setup now checks for an open local folder before starting prerequisites
or downloading source. With an empty VS Code window it offers **Choose Project
Folder**, verifies write access and opens that folder in VS Code. A short-lived
continuation record contains only the chosen folder and time. Once that same
folder is open and trusted, extension activation resumes setup and consumes
the record. Different folders, expired records and untrusted workspaces do
not trigger continuation. VS Code's trust decision remains the user's.

An in-progress setup promise prevents repeated clicks from starting another
installation in the same window. Existing complete source checkouts are
reused. Source copying still refuses conflicting user files; credential and
assistant configuration safeguards remain in place.

## Visible long-running work

The setup page lists folder, Cygwin, Java, GitHub source, libraries, SAS access
and assistant connection separately. Long stages update an elapsed-time
notification and checklist every ten seconds. The official Cygwin installer
retains its established unattended arguments, with `windowsHide: false`, so
its own progress window is visible. No package manager is run from an active
Cygwin Bash to replace its loaded DLLs. Failed stages keep their error visible.

Elapsed time means the process is being monitored; it is not a fabricated
percentage or a guarantee that the network is transferring data. Users are
told that downloads and compilation can exceed five minutes. Logs remain
available. Setup is not labelled as verified SAS execution merely because
software detection or tool discovery succeeded.

## SAS download and selected Python

The setup page explains the official SAS website sign-in, download, return
after redirect, and ZIP/folder selection. It does not invent an authenticated
download-button label, automate SAS account login or accept license terms.
Users obtain the encryption files from the
[SAS download page](https://support.sas.com/downloads/package.htm?pid=2494).
The requirement is also described by the
[official SASPy configuration documentation](https://sassoftware.github.io/saspy/configuration.html).

The ZIP/folder helper searches for exactly `sas.rutil.jar`, `sas.rutil.nls.jar`
and `sastpj.rutil.jar`. It validates the three JAR containers before copying,
rejects missing/invalid/conflicting copies, bounds directory traversal and
file size, skips directory symlinks, and never extracts unrelated archive paths.
Changed destination files are backed up. Files go into the Python environment
selected for the SAS target, rather than an unrelated installer interpreter.

Copying JARs alone can leave an older, installer-generated static classpath
incomplete. The helper repairs only the recognized managed assignment and
backs up its original configuration. Custom profiles are not rewritten; a
custom explicit classpath may still need the user to add the JARs. The final
instruction is to configure private ODA login and run **Test selected SAS** in
a fresh session. Local COM/STDIO targets do not need these JARs; custom IOM
profiles retain access to the helper.

## Video correspondence

The video player page now describes the current controls beside the existing
demonstration: folder selection can be guided, Cygwin has visible progress,
and ZIP/parent-folder selection replaces the older manual extraction screen.
The existing MP4, its homepage opening and its small caption layer are
unchanged. The site build verified the original 58,496,926-byte video against
SHA256 `702de3344bf01d90b83d46e950d392192ae0d120173483cd8a4decee93a47d55`.

## Validation and limits

- 52 Node extension tests passed, including empty-window continuation, trust
  boundaries, duplicate-click handling, a simulated six-minute heartbeat,
  visible Cygwin launch arguments and existing portable-Cygwin/SAS switching.
- Six Python JAR-helper tests passed. They exercise a real helper subprocess
  with an isolated test package, nested ZIP and folder inputs, invalid and
  conflicting files, backups, managed classpaths and custom-config preservation.
  Test JARs contain only synthetic manifests, not proprietary SAS classes.
- All 82 existing Python runtime tests passed. The Perl Java-guidance regression
  passed all 38 assertions, including the actual CLI error boundary.
- The isolated real VS Code host passed activation, all eleven commands,
  installer task success/failure, provider registration, and the setup webview
  content checks. Native screenshot capture could not be completed: the helper
  returned `FrameArrived timed out` / `window capture timed out` after recovery.
  A separate headless browser preview was rendered and inspected; it had no
  horizontal overflow and its fixed JAR-selection action worked. That preview
  is not presented as a real installation screenshot.

No new full Cygwin installation or fresh SAS account registration was performed
for these UI changes. The long-duration test advances a fixture clock. SAS's
authenticated download page is left for the user. Cross-platform CI results
belong to the published source revision and release build record; GUI launch
flags and isolated host checks do not establish a fresh end-to-end installation
on every desktop.
