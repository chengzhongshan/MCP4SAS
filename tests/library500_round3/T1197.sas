/* T1197 set_rename_swap, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1197a; x=8; y=9; run;
data t1197o; set t1197a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1197o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1197 rows=' rows;
else do; set t1197o; if not missing(actual) and abs(actual-(98))<=1e-10*max(1,abs(98)) then put 'ROUND3_PASS=T1197';
else put 'ERROR: ROUND3_FAIL=T1197 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1197:; quit;
