/* R724 lag_queue, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r724a; do x=1 to 5; value=x*x; output; end; run;
data r724b; set r724a; prev=lag(value); delta=value-prev; run;
proc sql; create table r724o as select sum(delta) as actual from r724b; quit;

data _null_; if 0 then set r724o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R724 rows=' rows;
else do; set r724o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND2_PASS=R724';
else put 'ERROR: ROUND2_FAIL=R724 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r724:; quit;
