/* F1855 rank_dense_ties, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1855a; do x=1 to 6; output; output; end; run;
proc rank data=f1855a out=f1855b ties=dense; var x; ranks position; run;
proc sql; create table f1855o as select max(position) as actual from f1855b; quit;

data _null_; if 0 then set f1855o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1855 rows=' rows;
else do; set f1855o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND4_PASS=F1855';
else put 'ERROR: ROUND4_FAIL=F1855 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1855:; quit;
