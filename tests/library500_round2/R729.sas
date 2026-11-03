/* R729 lag_queue, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r729a; do x=1 to 10; value=x*x; output; end; run;
data r729b; set r729a; prev=lag(value); delta=value-prev; run;
proc sql; create table r729o as select sum(delta) as actual from r729b; quit;

data _null_; if 0 then set r729o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R729 rows=' rows;
else do; set r729o; if not missing(actual) and abs(actual-(99))<=1e-10*max(1,abs(99)) then put 'ROUND2_PASS=R729';
else put 'ERROR: ROUND2_FAIL=R729 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r729:; quit;
