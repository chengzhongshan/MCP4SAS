/* T1351 leap_date_informat, N=2; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1351o; actual=input('29FEB1980',date9.); run;

data _null_; if 0 then set t1351o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1351 rows=' rows;
else do; set t1351o; if not missing(actual) and abs(actual-(7364))<=1e-10*max(1,abs(7364)) then put 'ROUND3_PASS=T1351';
else put 'ERROR: ROUND3_FAIL=T1351 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1351:; quit;
