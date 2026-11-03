/* R698 by_group_total, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r698a; do k=1 to 9; do x=1 to k; output; end; end; run;
data r698b; set r698a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r698o as select sum(total) as actual from r698b; quit;

data _null_; if 0 then set r698o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R698 rows=' rows;
else do; set r698o; if not missing(actual) and abs(actual-(165))<=1e-10*max(1,abs(165)) then put 'ROUND2_PASS=R698';
else put 'ERROR: ROUND2_FAIL=R698 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r698:; quit;
