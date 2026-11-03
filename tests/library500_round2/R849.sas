/* R849 merge_in_flags, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r849a; do k=1 to 10; output; end; run;
data r849b; do k=10 to 2*10; output; end; run;
data r849c; merge r849a(in=ina) r849b(in=inb); by k; if ina and not inb; run;
proc sql; create table r849o as select sum(k) as actual from r849c; quit;

data _null_; if 0 then set r849o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R849 rows=' rows;
else do; set r849o; if not missing(actual) and abs(actual-(45))<=1e-10*max(1,abs(45)) then put 'ROUND2_PASS=R849';
else put 'ERROR: ROUND2_FAIL=R849 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r849:; quit;
