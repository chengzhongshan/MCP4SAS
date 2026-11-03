/* T1262 transpose_let_last_value, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1262a; do value=1 to 3; id=1; output; end; run;
proc transpose data=t1262a out=t1262b let prefix=v; id id; var value; run;
data t1262o; set t1262b; actual=v1; run;

data _null_; if 0 then set t1262o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1262 rows=' rows;
else do; set t1262o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1262';
else put 'ERROR: ROUND3_FAIL=T1262 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1262:; quit;
