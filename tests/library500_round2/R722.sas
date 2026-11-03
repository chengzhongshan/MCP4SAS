/* R722 lag_queue, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r722a; do x=1 to 3; value=x*x; output; end; run;
data r722b; set r722a; prev=lag(value); delta=value-prev; run;
proc sql; create table r722o as select sum(delta) as actual from r722b; quit;

data _null_; if 0 then set r722o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R722 rows=' rows;
else do; set r722o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND2_PASS=R722';
else put 'ERROR: ROUND2_FAIL=R722 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r722:; quit;
