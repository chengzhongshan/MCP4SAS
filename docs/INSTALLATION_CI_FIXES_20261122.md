# Installation CI corrections

The failed [installation run](https://github.com/chengzhongshan/MCP4SAS/actions/runs/45097206480)
reached successful SASPy/Java checks and Perl syntax checks on every platform,
then stopped at an outdated macro-bootstrap assertion. The assertion required
an exact one-macro `grep` expression, although the implementation correctly
included both `Del_Dir_Recursive` and the portable `macroparas` fallback.

The guard now prepares an inert dependency request and verifies that both
supplemental loaders are present. It does not execute SAS or delete files.
It retains the checks on bootstrap state, macro-variable length, loader order,
API versions and conditional macro restoration. The fast runner workflow also
runs this guard, so a failure is visible before a full platform installation.

A related Windows installation failure in MultiGWAS-Explorer exposed a second
problem in the shared Python-discovery code. A minimal system interpreter can
import SASPy from `PYTHONPATH` while having no system `purelib` directory.
Discovery used to reject that interpreter based on the absent directory, then
could choose an unrelated Python from PATH. It now uses the import root
reported by the actual SASPy module/package specification. The existing
CRLF-record, submission, HTML and directory-listing regression now explicitly
simulates an absent system `purelib` directory on every platform.

Local Cygwin checks passed for the bootstrap guard, discovery regression,
portable macro autoload, connection lifecycle, PoC input boundaries, preflight
parity, SAS-supplied autocall handling, literal contexts and Python path
boundaries. These are offline installation/runtime checks; no SAS login,
scientific analysis or timing comparison is inferred from them. The GitHub
installation matrix remains the check of fresh Windows/Cygwin, macOS ARM,
macOS Intel, Ubuntu and Conda environments.

The fixes leave private configurations, credentials, SAS JARs and existing
persistent SAS sessions untouched. Missing licensed SAS encryption JARs still
receive the existing official-download instructions; CI does not download or
redistribute them.
