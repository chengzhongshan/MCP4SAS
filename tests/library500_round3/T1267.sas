/* T1267 transpose_let_last_value, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1267a; do value=1 to 8; id=1; output; end; run;
proc transpose data=t1267a out=t1267b let prefix=v; id id; var value; run;
data t1267o; set t1267b; actual=v1; run;

data _null_; if 0 then set t1267o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1267 rows=' rows;
else do; set t1267o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1267';
else put 'ERROR: ROUND3_FAIL=T1267 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1267:; quit;
