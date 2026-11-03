/* F1832 rank_groups_balanced, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1832a; do x=1 to 2*3; output; end; run;
proc rank data=f1832a out=f1832b groups=2; var x; ranks bin; run;
proc sql; create table f1832o as select sum(bin) as actual from f1832b; quit;

data _null_; if 0 then set f1832o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1832 rows=' rows;
else do; set f1832o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND4_PASS=F1832';
else put 'ERROR: ROUND4_FAIL=F1832 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1832:; quit;
