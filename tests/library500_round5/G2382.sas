/* G2382 sysevalf_ceiling, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2382value=%sysevalf(3/4,ceil);
data g2382o; actual=&g2382value; run;
%symdel g2382value;

data _null_; if 0 then set g2382o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2382 rows=' rows;
else do; set g2382o; if not missing(actual) and abs(actual-(1))<=1e-9*max(1,abs(1)) then put 'ROUND5_PASS=G2382';
else put 'ERROR: ROUND5_FAIL=G2382 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2382:; quit;
