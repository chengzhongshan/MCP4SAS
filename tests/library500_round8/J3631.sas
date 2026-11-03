/* J3631 glm_interaction_parameter, N=2; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:721 */

data j3631a; do j=1 to 2; do sign=-1 to 1 by 2; x=sign*j; do z=-1 to 1 by 2; y=3+2*x+4*z+5*x*z; output; end; end; end; run;
ods output ParameterEstimates=j3631b;
proc glm data=j3631a; model y=x z x*z / solution; run; quit;
ods output close;
data j3631o; set j3631b; if upcase(parameter)='X*Z'; actual=estimate; run;

data _null_; if 0 then set j3631o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3631 rows=' rows;
else do; set j3631o; if not missing(actual) and abs(actual-(5))<=1e-6*max(1,abs(5)) then put 'ROUND8_PASS=J3631';
else put 'ERROR: ROUND8_FAIL=J3631 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3631:; quit;
