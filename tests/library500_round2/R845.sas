/* R845 merge_in_flags, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r845a; do k=1 to 6; output; end; run;
data r845b; do k=6 to 2*6; output; end; run;
data r845c; merge r845a(in=ina) r845b(in=inb); by k; if ina and not inb; run;
proc sql; create table r845o as select sum(k) as actual from r845c; quit;

data _null_; if 0 then set r845o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R845 rows=' rows;
else do; set r845o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R845';
else put 'ERROR: ROUND2_FAIL=R845 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r845:; quit;
