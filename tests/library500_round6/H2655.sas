/* H2655 prx_lookahead, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2655o; actual=6+prxmatch('/[0-9]+(?=bp)/','pos6bp'); run;

data _null_; if 0 then set h2655o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2655 rows=' rows;
else do; set h2655o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2655';
else put 'ERROR: ROUND6_FAIL=H2655 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2655:; quit;
