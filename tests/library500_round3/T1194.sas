/* T1194 set_rename_swap, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1194a; x=5; y=6; run;
data t1194o; set t1194a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1194o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1194 rows=' rows;
else do; set t1194o; if not missing(actual) and abs(actual-(65))<=1e-10*max(1,abs(65)) then put 'ROUND3_PASS=T1194';
else put 'ERROR: ROUND3_FAIL=T1194 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1194:; quit;
