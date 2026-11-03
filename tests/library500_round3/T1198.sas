/* T1198 set_rename_swap, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1198a; x=9; y=10; run;
data t1198o; set t1198a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1198o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1198 rows=' rows;
else do; set t1198o; if not missing(actual) and abs(actual-(109))<=1e-10*max(1,abs(109)) then put 'ROUND3_PASS=T1198';
else put 'ERROR: ROUND3_FAIL=T1198 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1198:; quit;
