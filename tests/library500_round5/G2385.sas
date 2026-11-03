/* G2385 sysevalf_ceiling, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2385value=%sysevalf(6/4,ceil);
data g2385o; actual=&g2385value; run;
%symdel g2385value;

data _null_; if 0 then set g2385o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2385 rows=' rows;
else do; set g2385o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2385';
else put 'ERROR: ROUND5_FAIL=G2385 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2385:; quit;
