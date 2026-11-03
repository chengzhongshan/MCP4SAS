/* H2652 prx_lookahead, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2652o; actual=3+prxmatch('/[0-9]+(?=bp)/','pos3bp'); run;

data _null_; if 0 then set h2652o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2652 rows=' rows;
else do; set h2652o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2652';
else put 'ERROR: ROUND6_FAIL=H2652 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2652:; quit;
