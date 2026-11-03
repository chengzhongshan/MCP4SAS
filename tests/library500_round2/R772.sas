/* R772 transpose_roundtrip, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r772a; do k=1 to 3; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r772a out=r772b prefix=v; by k; id visit; var value; run;
proc sql; create table r772o as select sum(v2-v1) as actual from r772b; quit;

data _null_; if 0 then set r772o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R772 rows=' rows;
else do; set r772o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R772';
else put 'ERROR: ROUND2_FAIL=R772 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r772:; quit;
