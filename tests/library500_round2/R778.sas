/* R778 transpose_roundtrip, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r778a; do k=1 to 9; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r778a out=r778b prefix=v; by k; id visit; var value; run;
proc sql; create table r778o as select sum(v2-v1) as actual from r778b; quit;

data _null_; if 0 then set r778o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R778 rows=' rows;
else do; set r778o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND2_PASS=R778';
else put 'ERROR: ROUND2_FAIL=R778 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r778:; quit;
