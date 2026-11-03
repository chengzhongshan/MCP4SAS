/* G2393 eval_boolean_expression, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2393value=%eval((4>5) and (%sysfunc(mod(4,2))=0));
data g2393o; actual=&g2393value; run;
%symdel g2393value;

data _null_; if 0 then set g2393o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2393 rows=' rows;
else do; set g2393o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND5_PASS=G2393';
else put 'ERROR: ROUND5_FAIL=G2393 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2393:; quit;
