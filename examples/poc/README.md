# Run the MCP4SAS proof of concept examples

Start with the [showcase guide](../../docs/poc/README.md) for the scientifically
edited PoC, appendix, original figures and interpretation. Configure MCP4SAS's
SAS connection before executing these examples.

From the repository root:

```bash
perl examples/poc/run_example.pl --list
perl examples/poc/run_example.pl --case hello
perl examples/poc/run_example.pl --case clustergram
perl examples/poc/run_example.pl --case gene_gtf
perl examples/poc/run_example.pl --case oncoprint
perl examples/poc/run_example.pl --case forest
perl examples/poc/run_example.pl --case multi_gwas_gtf
```

Run them sequentially. The default session is `poc_showcase`; supply
`--session-id NAME` to select another. Each run creates a new local output
directory. Use `--outdir DIR` to choose its location, or `--dry-run` to inspect
the plan without running SAS. An existing output directory is preserved.

The helper uses MCP4SAS's Perl runner, so it can execute saved code without an
AI agent. For an agent-driven run, use [PROMPTS.md](PROMPTS.md) and the configured
MCP tools. The same session must remain available until files are collected
from the `POC_OUT` directory recorded in the SAS log.

The five scientific programs are the complete retained SAS payloads, including
their original macro definitions. Most of their length is reusable macro code;
the actual display calls appear near the end. `hello.sas` is a short beginner
example. Global macro autoload is disabled by the helper because the scientific
programs already contain their definitions. Syntax and dependency checks retain
the user's configured settings.

To check previously collected files:

```bash
perl examples/poc/validate_outputs.pl --case oncoprint --dir PATH_TO_RESULTS/files
```

The checker uses core Perl modules. It verifies the listed outputs and row
counts, then selected independent transformations or arithmetic. It does not
certify scientific validity or publication quality. Preserve and inspect the
complete SAS log, including warnings.

The [manifest](manifest.json) records document/program/input hashes, expected
CSV counts, completion markers and retained evidence identifiers.
[PROVENANCE.md](PROVENANCE.md) records source scope. The oncoprint is synthetic;
the other scientific cases use prepared summary data rather than full raw-study
pipelines. No credentials or account-specific SAS configuration are included.
