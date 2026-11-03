/* T1358 leap_date_informat, N=9; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1358o; actual=input('29FEB2008',date9.); run;

data _null_; if 0 then set t1358o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1358 rows=' rows;
else do; set t1358o; if not missing(actual) and abs(actual-(17591))<=1e-10*max(1,abs(17591)) then put 'ROUND3_PASS=T1358';
else put 'ERROR: ROUND3_FAIL=T1358 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1358:; quit;
