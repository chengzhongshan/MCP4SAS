/* G2399 eval_boolean_expression, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2399value=%eval((10>5) and (%sysfunc(mod(10,2))=0));
data g2399o; actual=&g2399value; run;
%symdel g2399value;

data _null_; if 0 then set g2399o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2399 rows=' rows;
else do; set g2399o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2399';
else put 'ERROR: ROUND5_FAIL=G2399 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2399:; quit;
