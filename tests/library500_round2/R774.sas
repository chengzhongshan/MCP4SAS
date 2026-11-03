/* R774 transpose_roundtrip, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r774a; do k=1 to 5; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r774a out=r774b prefix=v; by k; id visit; var value; run;
proc sql; create table r774o as select sum(v2-v1) as actual from r774b; quit;

data _null_; if 0 then set r774o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R774 rows=' rows;
else do; set r774o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND2_PASS=R774';
else put 'ERROR: ROUND2_FAIL=R774 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r774:; quit;
