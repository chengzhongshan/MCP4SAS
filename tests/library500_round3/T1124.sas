/* T1124 user_informat, N=5; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1124f 'code5'=15 other=.; run;
data t1124o; actual=input('code5',t1124f.); run;

data _null_; if 0 then set t1124o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1124 rows=' rows;
else do; set t1124o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND3_PASS=T1124';
else put 'ERROR: ROUND3_FAIL=T1124 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1124:; quit;
proc catalog catalog=work.formats; delete t1124f.infmt; quit;
