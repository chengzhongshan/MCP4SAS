/* T1269 transpose_let_last_value, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1269a; do value=1 to 10; id=1; output; end; run;
proc transpose data=t1269a out=t1269b let prefix=v; id id; var value; run;
data t1269o; set t1269b; actual=v1; run;

data _null_; if 0 then set t1269o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1269 rows=' rows;
else do; set t1269o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1269';
else put 'ERROR: ROUND3_FAIL=T1269 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1269:; quit;
