/* R777 transpose_roundtrip, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:49 */

data r777a; do k=1 to 8; do visit=1 to 2; value=10*k+visit; output; end; end; run;
proc transpose data=r777a out=r777b prefix=v; by k; id visit; var value; run;
proc sql; create table r777o as select sum(v2-v1) as actual from r777b; quit;

data _null_; if 0 then set r777o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R777 rows=' rows;
else do; set r777o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R777';
else put 'ERROR: ROUND2_FAIL=R777 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r777:; quit;
