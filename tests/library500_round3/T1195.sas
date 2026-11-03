/* T1195 set_rename_swap, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1195a; x=6; y=7; run;
data t1195o; set t1195a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1195o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1195 rows=' rows;
else do; set t1195o; if not missing(actual) and abs(actual-(76))<=1e-10*max(1,abs(76)) then put 'ROUND3_PASS=T1195';
else put 'ERROR: ROUND3_FAIL=T1195 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1195:; quit;
