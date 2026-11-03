/* T1125 user_informat, N=6; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1125f 'code6'=18 other=.; run;
data t1125o; actual=input('code6',t1125f.); run;

data _null_; if 0 then set t1125o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1125 rows=' rows;
else do; set t1125o; if not missing(actual) and abs(actual-(18))<=1e-10*max(1,abs(18)) then put 'ROUND3_PASS=T1125';
else put 'ERROR: ROUND3_FAIL=T1125 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1125:; quit;
proc catalog catalog=work.formats; delete t1125f.infmt; quit;
