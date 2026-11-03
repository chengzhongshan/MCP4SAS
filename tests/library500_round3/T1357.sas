/* T1357 leap_date_informat, N=8; source: SAS-Useful-Codes/Macros/MacroNotUsed/sas2xls.sas:713 */

data t1357o; actual=input('29FEB2004',date9.); run;

data _null_; if 0 then set t1357o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1357 rows=' rows;
else do; set t1357o; if not missing(actual) and abs(actual-(16130))<=1e-10*max(1,abs(16130)) then put 'ROUND3_PASS=T1357';
else put 'ERROR: ROUND3_FAIL=T1357 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1357:; quit;
