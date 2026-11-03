/* R796 rank_ties, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r796a; do x=1 to 7; output; output; end; run;
proc rank data=r796a out=r796b ties=mean; var x; ranks position; run;
proc sql; create table r796o as select sum(position) as actual from r796b; quit;

data _null_; if 0 then set r796o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R796 rows=' rows;
else do; set r796o; if not missing(actual) and abs(actual-(105))<=1e-10*max(1,abs(105)) then put 'ROUND2_PASS=R796';
else put 'ERROR: ROUND2_FAIL=R796 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r796:; quit;
