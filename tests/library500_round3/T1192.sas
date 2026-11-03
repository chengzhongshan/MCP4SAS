/* T1192 set_rename_swap, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1192a; x=3; y=4; run;
data t1192o; set t1192a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1192o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1192 rows=' rows;
else do; set t1192o; if not missing(actual) and abs(actual-(43))<=1e-10*max(1,abs(43)) then put 'ROUND3_PASS=T1192';
else put 'ERROR: ROUND3_FAIL=T1192 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1192:; quit;
