/* G2387 sysevalf_ceiling, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2387value=%sysevalf(8/4,ceil);
data g2387o; actual=&g2387value; run;
%symdel g2387value;

data _null_; if 0 then set g2387o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2387 rows=' rows;
else do; set g2387o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2387';
else put 'ERROR: ROUND5_FAIL=G2387 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2387:; quit;
