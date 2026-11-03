/* R779 transpose_roundtrip, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r779a; do k=1 to 10; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r779a out=r779b prefix=v; by k; id visit; var value; run;
proc sql; create table r779o as select sum(v2-v1) as actual from r779b; quit;

data _null_; if 0 then set r779o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R779 rows=' rows;
else do; set r779o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R779';
else put 'ERROR: ROUND2_FAIL=R779 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r779:; quit;
