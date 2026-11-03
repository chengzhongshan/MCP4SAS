/* T1356 leap_date_informat, N=7; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1356o; actual=input('29FEB2000',date9.); run;

data _null_; if 0 then set t1356o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1356 rows=' rows;
else do; set t1356o; if not missing(actual) and abs(actual-(14669))<=1e-10*max(1,abs(14669)) then put 'ROUND3_PASS=T1356';
else put 'ERROR: ROUND3_FAIL=T1356 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1356:; quit;
