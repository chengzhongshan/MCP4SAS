/* G2390 sysevalf_ceiling, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2390value=%sysevalf(11/4,ceil);
data g2390o; actual=&g2390value; run;
%symdel g2390value;

data _null_; if 0 then set g2390o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2390 rows=' rows;
else do; set g2390o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND5_PASS=G2390';
else put 'ERROR: ROUND5_FAIL=G2390 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2390:; quit;
