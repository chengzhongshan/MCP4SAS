/* R721 lag_queue, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r721a; do x=1 to 2; value=x*x; output; end; run;
data r721b; set r721a; prev=lag(value); delta=value-prev; run;
proc sql; create table r721o as select sum(delta) as actual from r721b; quit;

data _null_; if 0 then set r721o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R721 rows=' rows;
else do; set r721o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND2_PASS=R721';
else put 'ERROR: ROUND2_FAIL=R721 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r721:; quit;
