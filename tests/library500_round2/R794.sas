/* R794 rank_ties, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r794a; do x=1 to 5; output; output; end; run;
proc rank data=r794a out=r794b ties=mean; var x; ranks position; run;
proc sql; create table r794o as select sum(position) as actual from r794b; quit;

data _null_; if 0 then set r794o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R794 rows=' rows;
else do; set r794o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R794';
else put 'ERROR: ROUND2_FAIL=R794 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r794:; quit;
