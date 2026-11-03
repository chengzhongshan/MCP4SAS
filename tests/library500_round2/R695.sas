/* R695 by_group_total, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r695a; do k=1 to 6; do x=1 to k; output; end; end; run;
data r695b; set r695a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r695o as select sum(total) as actual from r695b; quit;

data _null_; if 0 then set r695o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R695 rows=' rows;
else do; set r695o; if not missing(actual) and abs(actual-(56))<=1e-10*max(1,abs(56)) then put 'ROUND2_PASS=R695';
else put 'ERROR: ROUND2_FAIL=R695 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r695:; quit;
