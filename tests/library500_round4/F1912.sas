/* F1912 transpose_wide_long_checksum, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1912a; do k=1 to 3; value=k*k; output; end; run;
proc transpose data=f1912a out=f1912b prefix=v; id k; var value; run;
proc transpose data=f1912b(drop=_name_) out=f1912c prefix=back; var v1-v3; run;
proc sql; create table f1912o as select sum(back1) as actual from f1912c; quit;

data _null_; if 0 then set f1912o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1912 rows=' rows;
else do; set f1912o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND4_PASS=F1912';
else put 'ERROR: ROUND4_FAIL=F1912 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1912:; quit;
