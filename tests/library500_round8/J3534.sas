/* J3534 princomp_score_energy, N=5; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3534a; do j=1 to 5; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3534a cov out=j3534b noprint; var x y; run;
proc sql; create table j3534o as select sum(prin1*prin1) as actual from j3534b; quit;

data _null_; if 0 then set j3534o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3534 rows=' rows;
else do; set j3534o; if not missing(actual) and abs(actual-(550))<=1e-6*max(1,abs(550)) then put 'ROUND8_PASS=J3534';
else put 'ERROR: ROUND8_FAIL=J3534 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3534:; quit;
