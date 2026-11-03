/* R691 by_group_total, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r691a; do k=1 to 2; do x=1 to k; output; end; end; run;
data r691b; set r691a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r691o as select sum(total) as actual from r691b; quit;

data _null_; if 0 then set r691o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R691 rows=' rows;
else do; set r691o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND2_PASS=R691';
else put 'ERROR: ROUND2_FAIL=R691 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r691:; quit;
