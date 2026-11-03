/* T1268 transpose_let_last_value, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data t1268a; do value=1 to 9; id=1; output; end; run;
proc transpose data=t1268a out=t1268b let prefix=v; id id; var value; run;
data t1268o; set t1268b; actual=v1; run;

data _null_; if 0 then set t1268o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1268 rows=' rows;
else do; set t1268o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1268';
else put 'ERROR: ROUND3_FAIL=T1268 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1268:; quit;
