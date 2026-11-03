/* R692 by_group_total, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r692a; do k=1 to 3; do x=1 to k; output; end; end; run;
data r692b; set r692a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r692o as select sum(total) as actual from r692b; quit;

data _null_; if 0 then set r692o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R692 rows=' rows;
else do; set r692o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R692';
else put 'ERROR: ROUND2_FAIL=R692 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r692:; quit;
