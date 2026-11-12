# Active runner preflight performance correction

server.pl selects run_sas_codes_or_files_in_ODA.pl before run_sas_codes_or_script_in_ODA.pl. These are currently separate implementations. The earlier runtime-include guard was added only to the latter, so server-backed executions continued preflighting unresolved macro-variable paths. Apply the same guard to the active runner and test both entry points to prevent a one-sided fix.

The guard defers paths requiring SAS macro resolution to SAS execution. It does not disable all preflight checks, skip SAS execution, suppress SAS errors, or change macro definitions. Literal local and remote include paths remain eligible for inspection. Post-change clustergram submission completed in 15.45 seconds versus the original 292.27 seconds, with identical submitted code hashes. Full four-family output comparison is retained in the proof-of-concept evidence directory.

The persistent-session transfer_many implementation currently loops over individual upload/download calls, even when archive_transfers is enabled. The switch therefore does not supply ZIP batching on that branch. This remains a separate performance limitation; a safe persistent ZIP implementation needs dedicated extraction, integrity, cleanup and failure tests. Do not attribute the observed speedup to ZIP transfer or claim the earlier flag-only run used batched transfers.

Validation: active runner Perl syntax, 3 runner-path regression assertions and 16 existing dependency-discovery assertions passed. Original slow timings remain unchanged as the before record.
