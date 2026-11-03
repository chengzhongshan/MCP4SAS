/* G2395 eval_boolean_expression, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2395value=%eval((6>5) and (%sysfunc(mod(6,2))=0));
data g2395o; actual=&g2395value; run;
%symdel g2395value;

data _null_; if 0 then set g2395o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2395 rows=' rows;
else do; set g2395o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2395';
else put 'ERROR: ROUND5_FAIL=G2395 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2395:; quit;
