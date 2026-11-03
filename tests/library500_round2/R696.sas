/* R696 by_group_total, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r696a; do k=1 to 7; do x=1 to k; output; end; end; run;
data r696b; set r696a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r696o as select sum(total) as actual from r696b; quit;

data _null_; if 0 then set r696o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R696 rows=' rows;
else do; set r696o; if not missing(actual) and abs(actual-(84))<=1e-10*max(1,abs(84)) then put 'ROUND2_PASS=R696';
else put 'ERROR: ROUND2_FAIL=R696 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r696:; quit;
