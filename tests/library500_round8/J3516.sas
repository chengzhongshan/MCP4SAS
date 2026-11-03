/* J3516 princomp_correlation_eigenvalue, N=7; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:1818 */

data j3516a; do j=1 to 7; x=-j; y=2*x; output; x=j; y=2*x; output; end; run;
proc princomp data=j3516a outstat=j3516b noprint; var x y; run;
data j3516o; set j3516b; if _type_='EIGENVAL'; actual=x; run;

data _null_; if 0 then set j3516o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3516 rows=' rows;
else do; set j3516o; if not missing(actual) and abs(actual-(2))<=1e-6*max(1,abs(2)) then put 'ROUND8_PASS=J3516';
else put 'ERROR: ROUND8_FAIL=J3516 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3516:; quit;
