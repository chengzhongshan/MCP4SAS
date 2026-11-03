/* G2381 sysevalf_ceiling, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2381value=%sysevalf(2/4,ceil);
data g2381o; actual=&g2381value; run;
%symdel g2381value;

data _null_; if 0 then set g2381o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2381 rows=' rows;
else do; set g2381o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2381';
else put 'ERROR: ROUND5_FAIL=G2381 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2381:; quit;
