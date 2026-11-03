/* T1355 leap_date_informat, N=6; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1355o; actual=input('29FEB1996',date9.); run;

data _null_; if 0 then set t1355o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1355 rows=' rows;
else do; set t1355o; if not missing(actual) and abs(actual-(13208))<=1e-10*max(1,abs(13208)) then put 'ROUND3_PASS=T1355';
else put 'ERROR: ROUND3_FAIL=T1355 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1355:; quit;
