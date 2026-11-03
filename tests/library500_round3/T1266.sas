/* T1266 transpose_let_last_value, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1266a; do value=1 to 7; id=1; output; end; run;
proc transpose data=t1266a out=t1266b let prefix=v; id id; var value; run;
data t1266o; set t1266b; actual=v1; run;

data _null_; if 0 then set t1266o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1266 rows=' rows;
else do; set t1266o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1266';
else put 'ERROR: ROUND3_FAIL=T1266 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1266:; quit;
