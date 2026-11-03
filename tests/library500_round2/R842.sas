/* R842 merge_in_flags, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r842a; do k=1 to 3; output; end; run;
data r842b; do k=3 to 2*3; output; end; run;
data r842c; merge r842a(in=ina) r842b(in=inb); by k; if ina and not inb; run;
proc sql; create table r842o as select sum(k) as actual from r842c; quit;

data _null_; if 0 then set r842o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R842 rows=' rows;
else do; set r842o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R842';
else put 'ERROR: ROUND2_FAIL=R842 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r842:; quit;
