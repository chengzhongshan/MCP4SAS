/* R726 lag_queue, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r726a; do x=1 to 7; value=x*x; output; end; run;
data r726b; set r726a; prev=lag(value); delta=value-prev; run;
proc sql; create table r726o as select sum(delta) as actual from r726b; quit;

data _null_; if 0 then set r726o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R726 rows=' rows;
else do; set r726o; if not missing(actual) and abs(actual-(48))<=1e-10*max(1,abs(48)) then put 'ROUND2_PASS=R726';
else put 'ERROR: ROUND2_FAIL=R726 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r726:; quit;
