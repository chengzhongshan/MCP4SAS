/* R791 rank_ties, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r791a; do x=1 to 2; output; output; end; run;
proc rank data=r791a out=r791b ties=mean; var x; ranks position; run;
proc sql; create table r791o as select sum(position) as actual from r791b; quit;

data _null_; if 0 then set r791o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R791 rows=' rows;
else do; set r791o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND2_PASS=R791';
else put 'ERROR: ROUND2_FAIL=R791 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r791:; quit;
