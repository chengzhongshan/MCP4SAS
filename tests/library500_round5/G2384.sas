/* G2384 sysevalf_ceiling, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2384value=%sysevalf(5/4,ceil);
data g2384o; actual=&g2384value; run;
%symdel g2384value;

data _null_; if 0 then set g2384o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2384 rows=' rows;
else do; set g2384o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2384';
else put 'ERROR: ROUND5_FAIL=G2384 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2384:; quit;
