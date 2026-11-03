/* R699 by_group_total, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r699a; do k=1 to 10; do x=1 to k; output; end; end; run;
data r699b; set r699a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r699o as select sum(total) as actual from r699b; quit;

data _null_; if 0 then set r699o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R699 rows=' rows;
else do; set r699o; if not missing(actual) and abs(actual-(220))<=1e-10*max(1,abs(220)) then put 'ROUND2_PASS=R699';
else put 'ERROR: ROUND2_FAIL=R699 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r699:; quit;
