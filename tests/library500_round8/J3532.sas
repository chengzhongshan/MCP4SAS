/* J3532 princomp_score_energy, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3532a; do j=1 to 3; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3532a cov out=j3532b noprint; var x y; run;
proc sql; create table j3532o as select sum(prin1*prin1) as actual from j3532b; quit;

data _null_; if 0 then set j3532o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3532 rows=' rows;
else do; set j3532o; if not missing(actual) and abs(actual-(140))<=1e-6*max(1,abs(140)) then put 'ROUND8_PASS=J3532';
else put 'ERROR: ROUND8_FAIL=J3532 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3532:; quit;
