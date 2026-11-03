/* T1126 user_informat, N=7; source: SAS-Useful-Codes/Macros/SAS_ondemand_scripts/Use_proc_format_to_order_grps_for_proc_sgpanel.sas:3 */

proc format library=work; invalue t1126f 'code7'=21 other=.; run;
data t1126o; actual=input('code7',t1126f.); run;

data _null_; if 0 then set t1126o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1126 rows=' rows;
else do; set t1126o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND3_PASS=T1126';
else put 'ERROR: ROUND3_FAIL=T1126 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1126:; quit;
proc catalog catalog=work.formats; delete t1126f.infmt; quit;
