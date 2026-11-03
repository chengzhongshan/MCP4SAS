/* F1840 rank_groups_balanced, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1840a; do x=1 to 2*11; output; end; run;
proc rank data=f1840a out=f1840b groups=2; var x; ranks bin; run;
proc sql; create table f1840o as select sum(bin) as actual from f1840b; quit;

data _null_; if 0 then set f1840o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1840 rows=' rows;
else do; set f1840o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND4_PASS=F1840';
else put 'ERROR: ROUND4_FAIL=F1840 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1840:; quit;
