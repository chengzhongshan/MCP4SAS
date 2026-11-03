/* R725 lag_queue, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r725a; do x=1 to 6; value=x*x; output; end; run;
data r725b; set r725a; prev=lag(value); delta=value-prev; run;
proc sql; create table r725o as select sum(delta) as actual from r725b; quit;

data _null_; if 0 then set r725o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R725 rows=' rows;
else do; set r725o; if not missing(actual) and abs(actual-(35))<=1e-10*max(1,abs(35)) then put 'ROUND2_PASS=R725';
else put 'ERROR: ROUND2_FAIL=R725 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r725:; quit;
