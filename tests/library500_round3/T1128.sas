/* T1128 user_informat, N=9; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1128f 'code9'=27 other=.; run;
data t1128o; actual=input('code9',t1128f.); run;

data _null_; if 0 then set t1128o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1128 rows=' rows;
else do; set t1128o; if not missing(actual) and abs(actual-(27))<=1e-10*max(1,abs(27)) then put 'ROUND3_PASS=T1128';
else put 'ERROR: ROUND3_FAIL=T1128 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1128:; quit;
proc catalog catalog=work.formats; delete t1128f.infmt; quit;
