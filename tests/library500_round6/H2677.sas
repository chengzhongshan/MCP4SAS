/* H2677 prx_limit_one_replacement, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2677o; length text $40; text=prxchange('s/x/y/',1,'xxxxxxxx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2677o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2677 rows=' rows;
else do; set h2677o; if not missing(actual) and abs(actual-(17))<=1e-9*max(1,abs(17)) then put 'ROUND6_PASS=H2677';
else put 'ERROR: ROUND6_FAIL=H2677 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2677:; quit;
