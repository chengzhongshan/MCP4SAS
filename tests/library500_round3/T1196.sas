/* T1196 set_rename_swap, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1196a; x=7; y=8; run;
data t1196o; set t1196a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1196o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1196 rows=' rows;
else do; set t1196o; if not missing(actual) and abs(actual-(87))<=1e-10*max(1,abs(87)) then put 'ROUND3_PASS=T1196';
else put 'ERROR: ROUND3_FAIL=T1196 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1196:; quit;
