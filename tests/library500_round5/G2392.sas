/* G2392 eval_boolean_expression, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2392value=%eval((3>5) and (%sysfunc(mod(3,2))=0));
data g2392o; actual=&g2392value; run;
%symdel g2392value;

data _null_; if 0 then set g2392o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2392 rows=' rows;
else do; set g2392o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND5_PASS=G2392';
else put 'ERROR: ROUND5_FAIL=G2392 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2392:; quit;
