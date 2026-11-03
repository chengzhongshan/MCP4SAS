/* F1914 transpose_wide_long_checksum, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1914a; do k=1 to 5; value=k*k; output; end; run;
proc transpose data=f1914a out=f1914b prefix=v; id k; var value; run;
proc transpose data=f1914b(drop=_name_) out=f1914c prefix=back; var v1-v5; run;
proc sql; create table f1914o as select sum(back1) as actual from f1914c; quit;

data _null_; if 0 then set f1914o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1914 rows=' rows;
else do; set f1914o; if not missing(actual) and abs(actual-(55))<=1e-9*max(1,abs(55)) then put 'ROUND4_PASS=F1914';
else put 'ERROR: ROUND4_FAIL=F1914 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1914:; quit;
