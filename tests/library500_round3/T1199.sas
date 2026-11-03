/* T1199 set_rename_swap, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1199a; x=10; y=11; run;
data t1199o; set t1199a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1199o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1199 rows=' rows;
else do; set t1199o; if not missing(actual) and abs(actual-(120))<=1e-10*max(1,abs(120)) then put 'ROUND3_PASS=T1199';
else put 'ERROR: ROUND3_FAIL=T1199 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1199:; quit;
