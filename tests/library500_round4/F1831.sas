/* F1831 rank_groups_balanced, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1831a; do x=1 to 2*2; output; end; run;
proc rank data=f1831a out=f1831b groups=2; var x; ranks bin; run;
proc sql; create table f1831o as select sum(bin) as actual from f1831b; quit;

data _null_; if 0 then set f1831o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1831 rows=' rows;
else do; set f1831o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND4_PASS=F1831';
else put 'ERROR: ROUND4_FAIL=F1831 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1831:; quit;
