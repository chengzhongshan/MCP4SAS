/* F1918 transpose_wide_long_checksum, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1918a; do k=1 to 9; value=k*k; output; end; run;
proc transpose data=f1918a out=f1918b prefix=v; id k; var value; run;
proc transpose data=f1918b(drop=_name_) out=f1918c prefix=back; var v1-v9; run;
proc sql; create table f1918o as select sum(back1) as actual from f1918c; quit;

data _null_; if 0 then set f1918o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1918 rows=' rows;
else do; set f1918o; if not missing(actual) and abs(actual-(285))<=1e-9*max(1,abs(285)) then put 'ROUND4_PASS=F1918';
else put 'ERROR: ROUND4_FAIL=F1918 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1918:; quit;
