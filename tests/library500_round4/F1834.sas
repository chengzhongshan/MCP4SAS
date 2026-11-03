/* F1834 rank_groups_balanced, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1834a; do x=1 to 2*5; output; end; run;
proc rank data=f1834a out=f1834b groups=2; var x; ranks bin; run;
proc sql; create table f1834o as select sum(bin) as actual from f1834b; quit;

data _null_; if 0 then set f1834o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1834 rows=' rows;
else do; set f1834o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND4_PASS=F1834';
else put 'ERROR: ROUND4_FAIL=F1834 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1834:; quit;
