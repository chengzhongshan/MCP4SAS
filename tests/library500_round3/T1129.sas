/* T1129 user_informat, N=10; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1129f 'code10'=30 other=.; run;
data t1129o; actual=input('code10',t1129f.); run;

data _null_; if 0 then set t1129o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1129 rows=' rows;
else do; set t1129o; if not missing(actual) and abs(actual-(30))<=1e-10*max(1,abs(30)) then put 'ROUND3_PASS=T1129';
else put 'ERROR: ROUND3_FAIL=T1129 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1129:; quit;
proc catalog catalog=work.formats; delete t1129f.infmt; quit;
