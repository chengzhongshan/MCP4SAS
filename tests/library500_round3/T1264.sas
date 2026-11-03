/* T1264 transpose_let_last_value, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1264a; do value=1 to 5; id=1; output; end; run;
proc transpose data=t1264a out=t1264b let prefix=v; id id; var value; run;
data t1264o; set t1264b; actual=v1; run;

data _null_; if 0 then set t1264o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1264 rows=' rows;
else do; set t1264o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1264';
else put 'ERROR: ROUND3_FAIL=T1264 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1264:; quit;
