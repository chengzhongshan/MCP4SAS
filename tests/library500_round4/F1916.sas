/* F1916 transpose_wide_long_checksum, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1916a; do k=1 to 7; value=k*k; output; end; run;
proc transpose data=f1916a out=f1916b prefix=v; id k; var value; run;
proc transpose data=f1916b(drop=_name_) out=f1916c prefix=back; var v1-v7; run;
proc sql; create table f1916o as select sum(back1) as actual from f1916c; quit;

data _null_; if 0 then set f1916o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1916 rows=' rows;
else do; set f1916o; if not missing(actual) and abs(actual-(140))<=1e-9*max(1,abs(140)) then put 'ROUND4_PASS=F1916';
else put 'ERROR: ROUND4_FAIL=F1916 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1916:; quit;
