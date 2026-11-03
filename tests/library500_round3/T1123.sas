/* T1123 user_informat, N=4; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1123f 'code4'=12 other=.; run;
data t1123o; actual=input('code4',t1123f.); run;

data _null_; if 0 then set t1123o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1123 rows=' rows;
else do; set t1123o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1123';
else put 'ERROR: ROUND3_FAIL=T1123 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1123:; quit;
proc catalog catalog=work.formats; delete t1123f.infmt; quit;
