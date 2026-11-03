/* F1898 sql_standard_error, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Be caution about Proc SQL Left Join when there are duplicates in the right table.sas:1 */

data f1898a; do x=1 to 9; output; end; run;
proc sql; create table f1898o as select stderr(x) as actual from f1898a; quit;

data _null_; if 0 then set f1898o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1898 rows=' rows;
else do; set f1898o; if not missing(actual) and abs(actual-(0.912870929175277))<=1e-9*max(1,abs(0.912870929175277)) then put 'ROUND4_PASS=F1898';
else put 'ERROR: ROUND4_FAIL=F1898 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1898:; quit;
