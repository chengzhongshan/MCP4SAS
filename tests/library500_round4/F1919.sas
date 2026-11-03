/* F1919 transpose_wide_long_checksum, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1919a; do k=1 to 10; value=k*k; output; end; run;
proc transpose data=f1919a out=f1919b prefix=v; id k; var value; run;
proc transpose data=f1919b(drop=_name_) out=f1919c prefix=back; var v1-v10; run;
proc sql; create table f1919o as select sum(back1) as actual from f1919c; quit;

data _null_; if 0 then set f1919o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1919 rows=' rows;
else do; set f1919o; if not missing(actual) and abs(actual-(385))<=1e-9*max(1,abs(385)) then put 'ROUND4_PASS=F1919';
else put 'ERROR: ROUND4_FAIL=F1919 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1919:; quit;
