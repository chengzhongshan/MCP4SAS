/* R848 merge_in_flags, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r848a; do k=1 to 9; output; end; run;
data r848b; do k=9 to 2*9; output; end; run;
data r848c; merge r848a(in=ina) r848b(in=inb); by k; if ina and not inb; run;
proc sql; create table r848o as select sum(k) as actual from r848c; quit;

data _null_; if 0 then set r848o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R848 rows=' rows;
else do; set r848o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R848';
else put 'ERROR: ROUND2_FAIL=R848 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r848:; quit;
