/* R694 by_group_total, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r694a; do k=1 to 5; do x=1 to k; output; end; end; run;
data r694b; set r694a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r694o as select sum(total) as actual from r694b; quit;

data _null_; if 0 then set r694o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R694 rows=' rows;
else do; set r694o; if not missing(actual) and abs(actual-(35))<=1e-10*max(1,abs(35)) then put 'ROUND2_PASS=R694';
else put 'ERROR: ROUND2_FAIL=R694 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r694:; quit;
