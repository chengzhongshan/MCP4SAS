/* H2602 prxposn_two_groups, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2602o; length text $60; text='item3:chr3'; re=prxparse('/^item([0-9]+):chr([0-9]+)$/'); matched=prxmatch(re,strip(text));
actual=input(prxposn(re,1,strip(text)),best32.)+input(prxposn(re,2,strip(text)),best32.); call prxfree(re); run;

data _null_; if 0 then set h2602o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2602 rows=' rows;
else do; set h2602o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2602';
else put 'ERROR: ROUND6_FAIL=H2602 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2602:; quit;
