/* F1835 rank_groups_balanced, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1835a; do x=1 to 2*6; output; end; run;
proc rank data=f1835a out=f1835b groups=2; var x; ranks bin; run;
proc sql; create table f1835o as select sum(bin) as actual from f1835b; quit;

data _null_; if 0 then set f1835o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1835 rows=' rows;
else do; set f1835o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1835';
else put 'ERROR: ROUND4_FAIL=F1835 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1835:; quit;
