/* J3540 princomp_score_energy, N=11; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3540a; do j=1 to 11; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3540a cov out=j3540b noprint; var x y; run;
proc sql; create table j3540o as select sum(prin1*prin1) as actual from j3540b; quit;

data _null_; if 0 then set j3540o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3540 rows=' rows;
else do; set j3540o; if not missing(actual) and abs(actual-(5060))<=1e-6*max(1,abs(5060)) then put 'ROUND8_PASS=J3540';
else put 'ERROR: ROUND8_FAIL=J3540 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3540:; quit;
