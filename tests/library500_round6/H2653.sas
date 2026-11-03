/* H2653 prx_lookahead, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2653o; actual=4+prxmatch('/[0-9]+(?=bp)/','pos4bp'); run;

data _null_; if 0 then set h2653o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2653 rows=' rows;
else do; set h2653o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2653';
else put 'ERROR: ROUND6_FAIL=H2653 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2653:; quit;
