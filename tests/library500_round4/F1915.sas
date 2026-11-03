/* F1915 transpose_wide_long_checksum, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1915a; do k=1 to 6; value=k*k; output; end; run;
proc transpose data=f1915a out=f1915b prefix=v; id k; var value; run;
proc transpose data=f1915b(drop=_name_) out=f1915c prefix=back; var v1-v6; run;
proc sql; create table f1915o as select sum(back1) as actual from f1915c; quit;

data _null_; if 0 then set f1915o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1915 rows=' rows;
else do; set f1915o; if not missing(actual) and abs(actual-(91))<=1e-9*max(1,abs(91)) then put 'ROUND4_PASS=F1915';
else put 'ERROR: ROUND4_FAIL=F1915 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1915:; quit;
