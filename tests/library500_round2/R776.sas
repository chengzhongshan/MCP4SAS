/* R776 transpose_roundtrip, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r776a; do k=1 to 7; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r776a out=r776b prefix=v; by k; id visit; var value; run;
proc sql; create table r776o as select sum(v2-v1) as actual from r776b; quit;

data _null_; if 0 then set r776o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R776 rows=' rows;
else do; set r776o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND2_PASS=R776';
else put 'ERROR: ROUND2_FAIL=R776 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r776:; quit;
