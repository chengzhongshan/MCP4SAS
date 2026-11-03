/* R800 rank_ties, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r800a; do x=1 to 11; output; output; end; run;
proc rank data=r800a out=r800b ties=mean; var x; ranks position; run;
proc sql; create table r800o as select sum(position) as actual from r800b; quit;

data _null_; if 0 then set r800o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R800 rows=' rows;
else do; set r800o; if not missing(actual) and abs(actual-(253))<=1e-10*max(1,abs(253)) then put 'ROUND2_PASS=R800';
else put 'ERROR: ROUND2_FAIL=R800 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r800:; quit;
