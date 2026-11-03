/* R793 rank_ties, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r793a; do x=1 to 4; output; output; end; run;
proc rank data=r793a out=r793b ties=mean; var x; ranks position; run;
proc sql; create table r793o as select sum(position) as actual from r793b; quit;

data _null_; if 0 then set r793o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R793 rows=' rows;
else do; set r793o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND2_PASS=R793';
else put 'ERROR: ROUND2_FAIL=R793 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r793:; quit;
