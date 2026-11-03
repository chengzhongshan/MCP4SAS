/* R844 merge_in_flags, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r844a; do k=1 to 5; output; end; run;
data r844b; do k=5 to 2*5; output; end; run;
data r844c; merge r844a(in=ina) r844b(in=inb); by k; if ina and not inb; run;
proc sql; create table r844o as select sum(k) as actual from r844c; quit;

data _null_; if 0 then set r844o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R844 rows=' rows;
else do; set r844o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R844';
else put 'ERROR: ROUND2_FAIL=R844 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r844:; quit;
