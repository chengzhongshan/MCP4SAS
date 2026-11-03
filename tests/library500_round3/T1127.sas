/* T1127 user_informat, N=8; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1127f 'code8'=24 other=.; run;
data t1127o; actual=input('code8',t1127f.); run;

data _null_; if 0 then set t1127o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1127 rows=' rows;
else do; set t1127o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND3_PASS=T1127';
else put 'ERROR: ROUND3_FAIL=T1127 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1127:; quit;
proc catalog catalog=work.formats; delete t1127f.infmt; quit;
