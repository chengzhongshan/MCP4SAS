/* G2398 eval_boolean_expression, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2398value=%eval((9>5) and (%sysfunc(mod(9,2))=0));
data g2398o; actual=&g2398value; run;
%symdel g2398value;

data _null_; if 0 then set g2398o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2398 rows=' rows;
else do; set g2398o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND5_PASS=G2398';
else put 'ERROR: ROUND5_FAIL=G2398 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2398:; quit;
