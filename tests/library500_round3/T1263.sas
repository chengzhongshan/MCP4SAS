/* T1263 transpose_let_last_value, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1263a; do value=1 to 4; id=1; output; end; run;
proc transpose data=t1263a out=t1263b let prefix=v; id id; var value; run;
data t1263o; set t1263b; actual=v1; run;

data _null_; if 0 then set t1263o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1263 rows=' rows;
else do; set t1263o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1263';
else put 'ERROR: ROUND3_FAIL=T1263 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1263:; quit;
