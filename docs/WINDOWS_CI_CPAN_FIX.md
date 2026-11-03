# Windows installation workflow: CPAN lookup failure

The [installation run for commit 7dfccae](https://github.com/chengzhongshan/MCP4SAS/actions/runs/41576259126)
failed in the Windows/Cygwin **Install from scratch** step. Cygwin installation,
the Python environment, SASPy and its Java/configuration setup had completed.
The Ubuntu, both macOS and Conda installation jobs passed.

The failure occurred while installing the declared Perl dependency `Mojolicious`:
cpanm could not resolve it through CPAN MetaDB, then could not download the
`http://www.cpan.org/` package index. The log does not establish the underlying
network/server cause. This happened before the SAS helper smoke tests.

`install/common.sh` now invokes cpanm with
`--from https://cpan.metacpan.org/`. That option uses the HTTPS mirror and its
index directly, avoiding default MetaDB lookup and HTTP fallback. See the
[official cpanm documentation](https://metacpan.org/dist/App-cpanminus/view/bin/cpanm#--from,-M).
`MCP4SAS_CPAN_MIRROR` can select another mirror explicitly. Cygwin still
bootstraps a Cygwin-native cpanm; the local Perl installation remains isolated.

`tests/test_installer_perl_deps.sh` verifies 25 assertions without network access:
Cygwin bootstrap, existing-cpanm reuse, the explicit default/custom mirror,
paths containing spaces and dependency-install failure propagation. All
installation jobs execute it before their real installer.

From the checkout in Cygwin:

```bash
bash tests/test_installer_perl_deps.sh
MCP4SAS_SKIP_CYGWIN_SETUP=1 bash install/install_cygwin.sh
```
