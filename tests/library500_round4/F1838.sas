/* F1838 rank_groups_balanced, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1838a; do x=1 to 2*9; output; end; run;
proc rank data=f1838a out=f1838b groups=2; var x; ranks bin; run;
proc sql; create table f1838o as select sum(bin) as actual from f1838b; quit;

data _null_; if 0 then set f1838o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1838 rows=' rows;
else do; set f1838o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND4_PASS=F1838';
else put 'ERROR: ROUND4_FAIL=F1838 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1838:; quit;
