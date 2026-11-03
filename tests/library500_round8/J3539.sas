/* J3539 princomp_score_energy, N=10; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3539a; do j=1 to 10; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3539a cov out=j3539b noprint; var x y; run;
proc sql; create table j3539o as select sum(prin1*prin1) as actual from j3539b; quit;

data _null_; if 0 then set j3539o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3539 rows=' rows;
else do; set j3539o; if not missing(actual) and abs(actual-(3850))<=1e-6*max(1,abs(3850)) then put 'ROUND8_PASS=J3539';
else put 'ERROR: ROUND8_FAIL=J3539 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3539:; quit;
