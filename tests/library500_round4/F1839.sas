/* F1839 rank_groups_balanced, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1839a; do x=1 to 2*10; output; end; run;
proc rank data=f1839a out=f1839b groups=2; var x; ranks bin; run;
proc sql; create table f1839o as select sum(bin) as actual from f1839b; quit;

data _null_; if 0 then set f1839o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1839 rows=' rows;
else do; set f1839o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND4_PASS=F1839';
else put 'ERROR: ROUND4_FAIL=F1839 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1839:; quit;
