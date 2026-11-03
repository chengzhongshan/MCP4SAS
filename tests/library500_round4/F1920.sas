/* F1920 transpose_wide_long_checksum, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1920a; do k=1 to 11; value=k*k; output; end; run;
proc transpose data=f1920a out=f1920b prefix=v; id k; var value; run;
proc transpose data=f1920b(drop=_name_) out=f1920c prefix=back; var v1-v11; run;
proc sql; create table f1920o as select sum(back1) as actual from f1920c; quit;

data _null_; if 0 then set f1920o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1920 rows=' rows;
else do; set f1920o; if not missing(actual) and abs(actual-(506))<=1e-9*max(1,abs(506)) then put 'ROUND4_PASS=F1920';
else put 'ERROR: ROUND4_FAIL=F1920 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1920:; quit;
