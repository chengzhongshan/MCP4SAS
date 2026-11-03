/* G2396 eval_boolean_expression, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2396value=%eval((7>5) and (%sysfunc(mod(7,2))=0));
data g2396o; actual=&g2396value; run;
%symdel g2396value;

data _null_; if 0 then set g2396o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2396 rows=' rows;
else do; set g2396o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND5_PASS=G2396';
else put 'ERROR: ROUND5_FAIL=G2396 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2396:; quit;
