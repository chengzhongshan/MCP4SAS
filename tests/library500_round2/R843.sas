/* R843 merge_in_flags, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Fisher's Z transformation and combine correlation form different dataset.sas:33 */

data r843a; do k=1 to 4; output; end; run;
data r843b; do k=4 to 2*4; output; end; run;
data r843c; merge r843a(in=ina) r843b(in=inb); by k; if ina and not inb; run;
proc sql; create table r843o as select sum(k) as actual from r843c; quit;

data _null_; if 0 then set r843o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R843 rows=' rows;
else do; set r843o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND2_PASS=R843';
else put 'ERROR: ROUND2_FAIL=R843 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r843:; quit;
