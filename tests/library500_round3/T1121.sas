/* T1121 user_informat, N=2; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1121f 'code2'=6 other=.; run;
data t1121o; actual=input('code2',t1121f.); run;

data _null_; if 0 then set t1121o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1121 rows=' rows;
else do; set t1121o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1121';
else put 'ERROR: ROUND3_FAIL=T1121 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1121:; quit;
proc catalog catalog=work.formats; delete t1121f.infmt; quit;
