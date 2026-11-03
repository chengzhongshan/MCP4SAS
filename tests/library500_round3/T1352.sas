/* T1352 leap_date_informat, N=3; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1352o; actual=input('29FEB1984',date9.); run;

data _null_; if 0 then set t1352o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1352 rows=' rows;
else do; set t1352o; if not missing(actual) and abs(actual-(8825))<=1e-10*max(1,abs(8825)) then put 'ROUND3_PASS=T1352';
else put 'ERROR: ROUND3_FAIL=T1352 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1352:; quit;
