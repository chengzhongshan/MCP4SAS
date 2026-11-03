/* H2660 prx_lookahead, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2660o; actual=11+prxmatch('/[0-9]+(?=bp)/','pos11bp'); run;

data _null_; if 0 then set h2660o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2660 rows=' rows;
else do; set h2660o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND6_PASS=H2660';
else put 'ERROR: ROUND6_FAIL=H2660 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2660:; quit;
