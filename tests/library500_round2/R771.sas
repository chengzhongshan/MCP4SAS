/* R771 transpose_roundtrip, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r771a; do k=1 to 2; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r771a out=r771b prefix=v; by k; id visit; var value; run;
proc sql; create table r771o as select sum(v2-v1) as actual from r771b; quit;

data _null_; if 0 then set r771o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R771 rows=' rows;
else do; set r771o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND2_PASS=R771';
else put 'ERROR: ROUND2_FAIL=R771 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r771:; quit;
