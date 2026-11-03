/* R780 transpose_roundtrip, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r780a; do k=1 to 11; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r780a out=r780b prefix=v; by k; id visit; var value; run;
proc sql; create table r780o as select sum(v2-v1) as actual from r780b; quit;

data _null_; if 0 then set r780o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R780 rows=' rows;
else do; set r780o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND2_PASS=R780';
else put 'ERROR: ROUND2_FAIL=R780 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r780:; quit;
