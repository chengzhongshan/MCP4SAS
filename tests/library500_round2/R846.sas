/* R846 merge_in_flags, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r846a; do k=1 to 7; output; end; run;
data r846b; do k=7 to 2*7; output; end; run;
data r846c; merge r846a(in=ina) r846b(in=inb); by k; if ina and not inb; run;
proc sql; create table r846o as select sum(k) as actual from r846c; quit;

data _null_; if 0 then set r846o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R846 rows=' rows;
else do; set r846o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R846';
else put 'ERROR: ROUND2_FAIL=R846 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r846:; quit;
