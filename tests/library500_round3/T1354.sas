/* T1354 leap_date_informat, N=5; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1354o; actual=input('29FEB1992',date9.); run;

data _null_; if 0 then set t1354o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1354 rows=' rows;
else do; set t1354o; if not missing(actual) and abs(actual-(11747))<=1e-10*max(1,abs(11747)) then put 'ROUND3_PASS=T1354';
else put 'ERROR: ROUND3_FAIL=T1354 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1354:; quit;
