/* J3531 princomp_score_energy, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3531a; do j=1 to 2; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3531a cov out=j3531b noprint; var x y; run;
proc sql; create table j3531o as select sum(prin1*prin1) as actual from j3531b; quit;

data _null_; if 0 then set j3531o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3531 rows=' rows;
else do; set j3531o; if not missing(actual) and abs(actual-(50))<=1e-6*max(1,abs(50)) then put 'ROUND8_PASS=J3531';
else put 'ERROR: ROUND8_FAIL=J3531 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3531:; quit;
