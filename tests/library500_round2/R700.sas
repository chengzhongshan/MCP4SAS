/* R700 by_group_total, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r700a; do k=1 to 11; do x=1 to k; output; end; end; run;
data r700b; set r700a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r700o as select sum(total) as actual from r700b; quit;

data _null_; if 0 then set r700o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R700 rows=' rows;
else do; set r700o; if not missing(actual) and abs(actual-(286))<=1e-10*max(1,abs(286)) then put 'ROUND2_PASS=R700';
else put 'ERROR: ROUND2_FAIL=R700 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r700:; quit;
