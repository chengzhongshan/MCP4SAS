/* R693 by_group_total, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/gwas_top_hits_manhattan demo.sas:20 */

data r693a; do k=1 to 4; do x=1 to k; output; end; end; run;
data r693b; set r693a; by k; if first.k then total=0; total+x; if last.k; run;
proc sql; create table r693o as select sum(total) as actual from r693b; quit;

data _null_; if 0 then set r693o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R693 rows=' rows;
else do; set r693o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND2_PASS=R693';
else put 'ERROR: ROUND2_FAIL=R693 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r693:; quit;
