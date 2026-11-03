/* G2400 eval_boolean_expression, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Macro do loop includes SAS procedures_No need to use _str_ for these procedure.sas:4 */

%let g2400value=%eval((11>5) and (%sysfunc(mod(11,2))=0));
data g2400o; actual=&g2400value; run;
%symdel g2400value;

data _null_; if 0 then set g2400o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2400 rows=' rows;
else do; set g2400o; if not missing(actual) and abs(actual-(0))<=1e-9*max(1,abs(0)) then put 'ROUND5_PASS=G2400';
else put 'ERROR: ROUND5_FAIL=G2400 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2400:; quit;
