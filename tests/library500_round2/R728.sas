/* R728 lag_queue, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r728a; do x=1 to 9; value=x*x; output; end; run;
data r728b; set r728a; prev=lag(value); delta=value-prev; run;
proc sql; create table r728o as select sum(delta) as actual from r728b; quit;

data _null_; if 0 then set r728o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R728 rows=' rows;
else do; set r728o; if not missing(actual) and abs(actual-(80))<=1e-10*max(1,abs(80)) then put 'ROUND2_PASS=R728';
else put 'ERROR: ROUND2_FAIL=R728 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r728:; quit;
