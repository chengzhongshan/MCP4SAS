/* H2605 prxposn_two_groups, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2605o; length text $60; text='item6:chr6'; re=prxparse('/^item([0-9]+):chr([0-9]+)$/'); matched=prxmatch(re,strip(text));
actual=input(prxposn(re,1,strip(text)),best32.)+input(prxposn(re,2,strip(text)),best32.); call prxfree(re); run;

data _null_; if 0 then set h2605o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2605 rows=' rows;
else do; set h2605o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2605';
else put 'ERROR: ROUND6_FAIL=H2605 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2605:; quit;
