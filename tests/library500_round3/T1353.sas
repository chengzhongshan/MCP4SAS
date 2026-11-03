/* T1353 leap_date_informat, N=4; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1353o; actual=input('29FEB1988',date9.); run;

data _null_; if 0 then set t1353o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1353 rows=' rows;
else do; set t1353o; if not missing(actual) and abs(actual-(10286))<=1e-10*max(1,abs(10286)) then put 'ROUND3_PASS=T1353';
else put 'ERROR: ROUND3_FAIL=T1353 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1353:; quit;
