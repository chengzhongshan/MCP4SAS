/* R775 transpose_roundtrip, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r775a; do k=1 to 6; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r775a out=r775b prefix=v; by k; id visit; var value; run;
proc sql; create table r775o as select sum(v2-v1) as actual from r775b; quit;

data _null_; if 0 then set r775o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R775 rows=' rows;
else do; set r775o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R775';
else put 'ERROR: ROUND2_FAIL=R775 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r775:; quit;
