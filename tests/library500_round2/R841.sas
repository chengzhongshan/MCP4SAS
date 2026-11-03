/* R841 merge_in_flags, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r841a; do k=1 to 2; output; end; run;
data r841b; do k=2 to 2*2; output; end; run;
data r841c; merge r841a(in=ina) r841b(in=inb); by k; if ina and not inb; run;
proc sql; create table r841o as select sum(k) as actual from r841c; quit;

data _null_; if 0 then set r841o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R841 rows=' rows;
else do; set r841o; if not missing(actual) and abs(actual-(1))<=1e-10*max(1,abs(1)) then put 'ROUND2_PASS=R841';
else put 'ERROR: ROUND2_FAIL=R841 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r841:; quit;
