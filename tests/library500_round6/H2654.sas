/* H2654 prx_lookahead, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2654o; actual=5+prxmatch('/[0-9]+(?=bp)/','pos5bp'); run;

data _null_; if 0 then set h2654o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2654 rows=' rows;
else do; set h2654o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2654';
else put 'ERROR: ROUND6_FAIL=H2654 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2654:; quit;
