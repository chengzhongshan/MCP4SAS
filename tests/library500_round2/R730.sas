/* R730 lag_queue, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/haplotype_associaiton.sas:74 */

data r730a; do x=1 to 11; value=x*x; output; end; run;
data r730b; set r730a; prev=lag(value); delta=value-prev; run;
proc sql; create table r730o as select sum(delta) as actual from r730b; quit;

data _null_; if 0 then set r730o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R730 rows=' rows;
else do; set r730o; if not missing(actual) and abs(actual-(120))<=1e-10*max(1,abs(120)) then put 'ROUND2_PASS=R730';
else put 'ERROR: ROUND2_FAIL=R730 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r730:; quit;
