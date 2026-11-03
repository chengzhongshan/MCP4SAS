/* G2391 eval_boolean_expression, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2391value=%eval((2>5) and (%sysfunc(mod(2,2))=0));
data g2391o; actual=&g2391value; run;
%symdel g2391value;

data _null_; if 0 then set g2391o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2391 rows=' rows;
else do; set g2391o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND5_PASS=G2391';
else put 'ERROR: ROUND5_FAIL=G2391 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2391:; quit;
