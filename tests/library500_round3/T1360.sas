/* T1360 leap_date_informat, N=11; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1360o; actual=input('29FEB2016',date9.); run;

data _null_; if 0 then set t1360o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1360 rows=' rows;
else do; set t1360o; if not missing(actual) and abs(actual-(20513))<=1e-10*max(1,abs(20513)) then put 'ROUND3_PASS=T1360';
else put 'ERROR: ROUND3_FAIL=T1360 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1360:; quit;
