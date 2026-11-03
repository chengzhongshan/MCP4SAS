/* T1122 user_informat, N=3; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1122f 'code3'=9 other=.; run;
data t1122o; actual=input('code3',t1122f.); run;

data _null_; if 0 then set t1122o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1122 rows=' rows;
else do; set t1122o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1122';
else put 'ERROR: ROUND3_FAIL=T1122 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1122:; quit;
proc catalog catalog=work.formats; delete t1122f.infmt; quit;
