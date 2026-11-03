/* H2606 prxposn_two_groups, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2606o; length text $60; text='item7:chr7'; re=prxparse('/^item([0-9]+):chr([0-9]+)$/'); matched=prxmatch(re,strip(text));
actual=input(prxposn(re,1,strip(text)),best32.)+input(prxposn(re,2,strip(text)),best32.); call prxfree(re); run;

data _null_; if 0 then set h2606o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2606 rows=' rows;
else do; set h2606o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND6_PASS=H2606';
else put 'ERROR: ROUND6_FAIL=H2606 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2606:; quit;
