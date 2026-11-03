/* R773 transpose_roundtrip, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r773a; do k=1 to 4; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r773a out=r773b prefix=v; by k; id visit; var value; run;
proc sql; create table r773o as select sum(v2-v1) as actual from r773b; quit;

data _null_; if 0 then set r773o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R773 rows=' rows;
else do; set r773o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R773';
else put 'ERROR: ROUND2_FAIL=R773 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r773:; quit;
