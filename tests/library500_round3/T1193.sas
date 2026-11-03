/* T1193 set_rename_swap, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1193a; x=4; y=5; run;
data t1193o; set t1193a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1193o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1193 rows=' rows;
else do; set t1193o; if not missing(actual) and abs(actual-(54))<=1e-10*max(1,abs(54)) then put 'ROUND3_PASS=T1193';
else put 'ERROR: ROUND3_FAIL=T1193 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1193:; quit;
