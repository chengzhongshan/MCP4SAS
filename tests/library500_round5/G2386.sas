/* G2386 sysevalf_ceiling, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/prxchange_replace_elements_within_multiple_quotes.sas:15 */

%let g2386value=%sysevalf(7/4,ceil);
data g2386o; actual=&g2386value; run;
%symdel g2386value;

data _null_; if 0 then set g2386o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND5_ROWS=G2386 rows=' rows;
else do; set g2386o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND5_PASS=G2386';
else put 'ERROR: ROUND5_FAIL=G2386 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete g2386:; quit;
