/* T1200 set_rename_swap, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1200a; x=11; y=12; run;
data t1200o; set t1200a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1200o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1200 rows=' rows;
else do; set t1200o; if not missing(actual) and abs(actual-(131))<=1e-10*max(1,abs(131)) then put 'ROUND3_PASS=T1200';
else put 'ERROR: ROUND3_FAIL=T1200 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1200:; quit;
