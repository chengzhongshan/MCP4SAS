/* F1911 transpose_wide_long_checksum, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1911a; do k=1 to 2; value=k*k; output; end; run;
proc transpose data=f1911a out=f1911b prefix=v; id k; var value; run;
proc transpose data=f1911b(drop=_name_) out=f1911c prefix=back; var v1-v2; run;
proc sql; create table f1911o as select sum(back1) as actual from f1911c; quit;

data _null_; if 0 then set f1911o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1911 rows=' rows;
else do; set f1911o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1911';
else put 'ERROR: ROUND4_FAIL=F1911 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1911:; quit;
