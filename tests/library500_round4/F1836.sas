/* F1836 rank_groups_balanced, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1836a; do x=1 to 2*7; output; end; run;
proc rank data=f1836a out=f1836b groups=2; var x; ranks bin; run;
proc sql; create table f1836o as select sum(bin) as actual from f1836b; quit;

data _null_; if 0 then set f1836o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1836 rows=' rows;
else do; set f1836o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND4_PASS=F1836';
else put 'ERROR: ROUND4_FAIL=F1836 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1836:; quit;
