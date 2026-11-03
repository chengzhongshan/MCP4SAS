/* H2601 prxposn_two_groups, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2601o; length text $60; text='item2:chr2'; re=prxparse('/^item([0-9]+):chr([0-9]+)$/'); matched=prxmatch(re,strip(text));
actual=input(prxposn(re,1,strip(text)),best32.)+input(prxposn(re,2,strip(text)),best32.); call prxfree(re); run;

data _null_; if 0 then set h2601o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2601 rows=' rows;
else do; set h2601o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2601';
else put 'ERROR: ROUND6_FAIL=H2601 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2601:; quit;
