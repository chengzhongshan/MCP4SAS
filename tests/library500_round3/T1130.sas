/* T1130 user_informat, N=11; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1130f 'code11'=33 other=.; run;
data t1130o; actual=input('code11',t1130f.); run;

data _null_; if 0 then set t1130o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1130 rows=' rows;
else do; set t1130o; if not missing(actual) and abs(actual-(33))<=1e-10*max(1,abs(33)) then put 'ROUND3_PASS=T1130';
else put 'ERROR: ROUND3_FAIL=T1130 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1130:; quit;
proc catalog catalog=work.formats; delete t1130f.infmt; quit;
