/* R723 lag_queue, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r723a; do x=1 to 4; value=x*x; output; end; run;
data r723b; set r723a; prev=lag(value); delta=value-prev; run;
proc sql; create table r723o as select sum(delta) as actual from r723b; quit;

data _null_; if 0 then set r723o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R723 rows=' rows;
else do; set r723o; if not missing(actual) and abs(actual-(15))<=1e-10*max(1,abs(15)) then put 'ROUND2_PASS=R723';
else put 'ERROR: ROUND2_FAIL=R723 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r723:; quit;
