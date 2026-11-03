/* H2659 prx_lookahead, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2659o; actual=10+prxmatch('/[0-9]+(?=bp)/','pos10bp'); run;

data _null_; if 0 then set h2659o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2659 rows=' rows;
else do; set h2659o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND6_PASS=H2659';
else put 'ERROR: ROUND6_FAIL=H2659 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2659:; quit;
