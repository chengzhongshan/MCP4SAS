/* T1359 leap_date_informat, N=10; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1359o; actual=input('29FEB2012',date9.); run;

data _null_; if 0 then set t1359o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1359 rows=' rows;
else do; set t1359o; if not missing(actual) and abs(actual-(19052))<=1e-10*max(1,abs(19052)) then put 'ROUND3_PASS=T1359';
else put 'ERROR: ROUND3_FAIL=T1359 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1359:; quit;
