/* G2389 sysevalf_ceiling, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2389value=%sysevalf(10/4,ceil);
data g2389o; actual=&g2389value; run;
%symdel g2389value;

data _null_; if 0 then set g2389o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2389 rows=' rows;
else do; set g2389o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2389';
else put 'ERROR: ROUND5_FAIL=G2389 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2389:; quit;
