/* H2658 prx_lookahead, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2658o; actual=9+prxmatch('/[0-9]+(?=bp)/','pos9bp'); run;

data _null_; if 0 then set h2658o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2658 rows=' rows;
else do; set h2658o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND6_PASS=H2658';
else put 'ERROR: ROUND6_FAIL=H2658 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2658:; quit;
