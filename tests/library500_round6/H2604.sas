/* H2604 prxposn_two_groups, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2604o; length text $60; text='item5:chr5'; re=prxparse('/^item([0-9]+):chr([0-9]+)$/'); matched=prxmatch(re,strip(text));
actual=input(prxposn(re,1,strip(text)),best32.)+input(prxposn(re,2,strip(text)),best32.); call prxfree(re); run;

data _null_; if 0 then set h2604o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2604 rows=' rows;
else do; set h2604o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2604';
else put 'ERROR: ROUND6_FAIL=H2604 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2604:; quit;
