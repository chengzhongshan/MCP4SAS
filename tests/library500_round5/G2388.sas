/* G2388 sysevalf_ceiling, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2388value=%sysevalf(9/4,ceil);
data g2388o; actual=&g2388value; run;
%symdel g2388value;

data _null_; if 0 then set g2388o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2388 rows=' rows;
else do; set g2388o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2388';
else put 'ERROR: ROUND5_FAIL=G2388 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2388:; quit;
