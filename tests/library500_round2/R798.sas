/* R798 rank_ties, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/make data step matrix with array.sas:10 */

data r798a; do x=1 to 9; output; output; end; run;
proc rank data=r798a out=r798b ties=mean; var x; ranks position; run;
proc sql; create table r798o as select sum(position) as actual from r798b; quit;

data _null_; if 0 then set r798o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R798 rows=' rows;
else do; set r798o; if not missing(actual) and abs(actual-(171))<=1e-10*max(1,abs(171)) then put 'ROUND2_PASS=R798';
else put 'ERROR: ROUND2_FAIL=R798 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r798:; quit;
