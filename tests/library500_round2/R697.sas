/* R697 by_group_total, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r697a; do k=1 to 8; do x=1 to k; output; end; end; run;
data r697b; set r697a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r697o as select sum(total) as actual from r697b; quit;

data _null_; if 0 then set r697o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R697 rows=' rows;
else do; set r697o; if not missing(actual) and abs(actual-(120))<=1e-10*max(1,abs(120)) then put 'ROUND2_PASS=R697';
else put 'ERROR: ROUND2_FAIL=R697 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r697:; quit;
