/* F1913 transpose_wide_long_checksum, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data f1913a; do k=1 to 4; value=k*k; output; end; run;
proc transpose data=f1913a out=f1913b prefix=v; id k; var value; run;
proc transpose data=f1913b(drop=_name_) out=f1913c prefix=back; var v1-v4; run;
proc sql; create table f1913o as select sum(back1) as actual from f1913c; quit;

data _null_; if 0 then set f1913o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1913 rows=' rows;
else do; set f1913o; if not missing(actual) and abs(actual-(30))<=1e-9*max(1,abs(30)) then put 'ROUND4_PASS=F1913';
else put 'ERROR: ROUND4_FAIL=F1913 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1913:; quit;
