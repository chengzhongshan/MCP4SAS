/* J3538 princomp_score_energy, N=9; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3538a; do j=1 to 9; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3538a cov out=j3538b noprint; var x y; run;
proc sql; create table j3538o as select sum(prin1*prin1) as actual from j3538b; quit;

data _null_; if 0 then set j3538o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3538 rows=' rows;
else do; set j3538o; if not missing(actual) and abs(actual-(2850))<=1e-6*max(1,abs(2850)) then put 'ROUND8_PASS=J3538';
else put 'ERROR: ROUND8_FAIL=J3538 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3538:; quit;
