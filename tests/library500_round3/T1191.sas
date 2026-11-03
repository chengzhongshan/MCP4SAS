/* T1191 set_rename_swap, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:56 */

data t1191a; x=2; y=3; run;
data t1191o; set t1191a(rename=(x=oldx y=x)); actual=10*x+oldx; run;

data _null_; if 0 then set t1191o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1191 rows=' rows;
else do; set t1191o; if not missing(actual) and abs(actual-(32))<=1e-10*max(1,abs(32)) then put 'ROUND3_PASS=T1191';
else put 'ERROR: ROUND3_FAIL=T1191 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1191:; quit;
