/* H2656 prx_lookahead, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2656o; actual=7+prxmatch('/[0-9]+(?=bp)/','pos7bp'); run;

data _null_; if 0 then set h2656o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2656 rows=' rows;
else do; set h2656o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2656';
else put 'ERROR: ROUND6_FAIL=H2656 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2656:; quit;
