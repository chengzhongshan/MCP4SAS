/* R795 rank_ties, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r795a; do x=1 to 6; output; output; end; run;
proc rank data=r795a out=r795b ties=mean; var x; ranks position; run;
proc sql; create table r795o as select sum(position) as actual from r795b; quit;

data _null_; if 0 then set r795o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R795 rows=' rows;
else do; set r795o; if not missing(actual) and abs(actual-(78))<=1e-10*max(1,abs(78)) then put 'ROUND2_PASS=R795';
else put 'ERROR: ROUND2_FAIL=R795 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r795:; quit;
