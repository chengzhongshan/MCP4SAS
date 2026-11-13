# Active runner preflight performance correction

Historical finding: server.pl selects run_sas_codes_or_files_in_ODA.pl before run_sas_codes_or_script_in_ODA.pl. The earlier runtime-include guard was initially added only to the latter, so server-backed executions continued preflighting unresolved macro-variable paths. Both entry points now contain the guard and are byte-identical. Their parity tests prevent a one-sided fix.

The guard defers paths requiring SAS macro resolution to SAS execution. It does not disable all preflight checks, skip SAS execution, suppress SAS errors, or change macro definitions. Literal local and remote include paths remain eligible for inspection. Post-change clustergram submission completed in 15.45 seconds versus the original 292.27 seconds, with identical submitted code hashes. Full four-family output comparison is retained in the proof-of-concept evidence directory.

At this stage of the investigation, persistent-session transfer_many still looped over individual calls even with archive_transfers enabled. That limitation was subsequently fixed with tested bulk RPC, integrity checks and cleanup. Do not attribute the include-guard-only speedup above to ZIP batching. The later source-analysis correction further reduced request time. See the current [performance debugging guide](PERFORMANCE_DEBUGGING.md) for the complete measured history and limitations.

Validation: active runner Perl syntax, 3 runner-path regression assertions and 16 existing dependency-discovery assertions passed. Original slow timings remain unchanged as the before record.
