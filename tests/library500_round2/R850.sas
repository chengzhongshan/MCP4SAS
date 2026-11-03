/* R850 merge_in_flags, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r850a; do k=1 to 11; output; end; run;
data r850b; do k=11 to 2*11; output; end; run;
data r850c; merge r850a(in=ina) r850b(in=inb); by k; if ina and not inb; run;
proc sql; create table r850o as select sum(k) as actual from r850c; quit;

data _null_; if 0 then set r850o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R850 rows=' rows;
else do; set r850o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R850';
else put 'ERROR: ROUND2_FAIL=R850 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r850:; quit;
