/* R847 merge_in_flags, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r847a; do k=1 to 8; output; end; run;
data r847b; do k=8 to 2*8; output; end; run;
data r847c; merge r847a(in=ina) r847b(in=inb); by k; if ina and not inb; run;
proc sql; create table r847o as select sum(k) as actual from r847c; quit;

data _null_; if 0 then set r847o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R847 rows=' rows;
else do; set r847o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND2_PASS=R847';
else put 'ERROR: ROUND2_FAIL=R847 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r847:; quit;
