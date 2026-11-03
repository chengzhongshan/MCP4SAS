/* R792 rank_ties, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r792a; do x=1 to 3; output; output; end; run;
proc rank data=r792a out=r792b ties=mean; var x; ranks position; run;
proc sql; create table r792o as select sum(position) as actual from r792b; quit;

data _null_; if 0 then set r792o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R792 rows=' rows;
else do; set r792o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND2_PASS=R792';
else put 'ERROR: ROUND2_FAIL=R792 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r792:; quit;
