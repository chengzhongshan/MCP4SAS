/* G2394 eval_boolean_expression, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2394value=%eval((5>5) and (%sysfunc(mod(5,2))=0));
data g2394o; actual=&g2394value; run;
%symdel g2394value;

data _null_; if 0 then set g2394o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2394 rows=' rows;
else do; set g2394o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND5_PASS=G2394';
else put 'ERROR: ROUND5_FAIL=G2394 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2394:; quit;
