/* T1270 transpose_let_last_value, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1270a; do value=1 to 11; id=1; output; end; run;
proc transpose data=t1270a out=t1270b let prefix=v; id id; var value; run;
data t1270o; set t1270b; actual=v1; run;

data _null_; if 0 then set t1270o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1270 rows=' rows;
else do; set t1270o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1270';
else put 'ERROR: ROUND3_FAIL=T1270 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1270:; quit;
