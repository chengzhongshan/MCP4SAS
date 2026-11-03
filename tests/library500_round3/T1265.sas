/* T1265 transpose_let_last_value, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1265a; do value=1 to 6; id=1; output; end; run;
proc transpose data=t1265a out=t1265b let prefix=v; id id; var value; run;
data t1265o; set t1265b; actual=v1; run;

data _null_; if 0 then set t1265o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1265 rows=' rows;
else do; set t1265o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1265';
else put 'ERROR: ROUND3_FAIL=T1265 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1265:; quit;
