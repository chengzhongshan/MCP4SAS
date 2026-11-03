/* J3632 glm_interaction_parameter, N=3; source: A Handbook of Statistical Analyses Using SAS, Second Edition.txt:721 */

data j3632a; do j=1 to 3; do sign=-1 to 1 by 2; x=sign*j; do z=-1 to 1 by 2; y=3+2*x+4*z+5*x*z; output; end; end; end; run;
ods output ParameterEstimates=j3632b;
proc glm data=j3632a; model y=x z x*z / solution; run; quit;
ods output close;
data j3632o; set j3632b; if upcase(parameter)='X*Z'; actual=estimate; run;

data _null_; if 0 then set j3632o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3632 rows=' rows;
else do; set j3632o; if not missing(actual) and abs(actual-(5))<=1e-6*max(1,abs(5)) then put 'ROUND8_PASS=J3632';
else put 'ERROR: ROUND8_FAIL=J3632 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3632:; quit;
