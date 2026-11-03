/* T1261 transpose_let_last_value, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1261a; do value=1 to 2; id=1; output; end; run;
proc transpose data=t1261a out=t1261b let prefix=v; id id; var value; run;
data t1261o; set t1261b; actual=v1; run;

data _null_; if 0 then set t1261o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1261 rows=' rows;
else do; set t1261o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1261';
else put 'ERROR: ROUND3_FAIL=T1261 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1261:; quit;
