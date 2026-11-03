/* J3536 princomp_score_energy, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3536a; do j=1 to 7; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3536a cov out=j3536b noprint; var x y; run;
proc sql; create table j3536o as select sum(prin1*prin1) as actual from j3536b; quit;

data _null_; if 0 then set j3536o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3536 rows=' rows;
else do; set j3536o; if not missing(actual) and abs(actual-(1400))<=1e-6*max(1,abs(1400)) then put 'ROUND8_PASS=J3536';
else put 'ERROR: ROUND8_FAIL=J3536 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3536:; quit;
