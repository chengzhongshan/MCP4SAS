/* R799 rank_ties, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r799a; do x=1 to 10; output; output; end; run;
proc rank data=r799a out=r799b ties=mean; var x; ranks position; run;
proc sql; create table r799o as select sum(position) as actual from r799b; quit;

data _null_; if 0 then set r799o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R799 rows=' rows;
else do; set r799o; if not missing(actual) and abs(actual-(210))<=1e-10*max(1,abs(210)) then put 'ROUND2_PASS=R799';
else put 'ERROR: ROUND2_FAIL=R799 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r799:; quit;
