/* G2397 eval_boolean_expression, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2397value=%eval((8>5) and (%sysfunc(mod(8,2))=0));
data g2397o; actual=&g2397value; run;
%symdel g2397value;

data _null_; if 0 then set g2397o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2397 rows=' rows;
else do; set g2397o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2397';
else put 'ERROR: ROUND5_FAIL=G2397 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2397:; quit;
