/* G2383 sysevalf_ceiling, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2383value=%sysevalf(4/4,ceil);
data g2383o; actual=&g2383value; run;
%symdel g2383value;

data _null_; if 0 then set g2383o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2383 rows=' rows;
else do; set g2383o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2383';
else put 'ERROR: ROUND5_FAIL=G2383 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2383:; quit;
