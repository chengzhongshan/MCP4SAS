/* F1917 transpose_wide_long_checksum, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1917a; do k=1 to 8; value=k*k; output; end; run;
proc transpose data=f1917a out=f1917b prefix=v; id k; var value; run;
proc transpose data=f1917b(drop=_name_) out=f1917c prefix=back; var v1-v8; run;
proc sql; create table f1917o as select sum(back1) as actual from f1917c; quit;

data _null_; if 0 then set f1917o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1917 rows=' rows;
else do; set f1917o; if not missing(actual) and abs(actual-(204))<=1e-9*max(1,abs(204)) then put 'ROUND4_PASS=F1917';
else put 'ERROR: ROUND4_FAIL=F1917 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1917:; quit;
