/* R727 lag_queue, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r727a; do x=1 to 8; value=x*x; output; end; run;
data r727b; set r727a; prev=lag(value); delta=value-prev; run;
proc sql; create table r727o as select sum(delta) as actual from r727b; quit;

data _null_; if 0 then set r727o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R727 rows=' rows;
else do; set r727o; if not missing(actual) and abs(actual-(63))<=1e-10*max(1,abs(63)) then put 'ROUND2_PASS=R727';
else put 'ERROR: ROUND2_FAIL=R727 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r727:; quit;
