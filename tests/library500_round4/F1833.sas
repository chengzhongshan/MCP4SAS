/* F1833 rank_groups_balanced, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data f1833a; do x=1 to 2*4; output; end; run;
proc rank data=f1833a out=f1833b groups=2; var x; ranks bin; run;
proc sql; create table f1833o as select sum(bin) as actual from f1833b; quit;

data _null_; if 0 then set f1833o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND4_ROWS=F1833 rows=' rows;
else do; set f1833o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND4_PASS=F1833';
else put 'ERROR: ROUND4_FAIL=F1833 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete f1833:; quit;
