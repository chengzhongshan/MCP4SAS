/* H2657 prx_lookahead, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2657o; actual=8+prxmatch('/[0-9]+(?=bp)/','pos8bp'); run;

data _null_; if 0 then set h2657o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2657 rows=' rows;
else do; set h2657o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2657';
else put 'ERROR: ROUND6_FAIL=H2657 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2657:; quit;
