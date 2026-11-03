/* H2679 prx_limit_one_replacement, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2679o; length text $40; text=prxchange('s/x/y/',1,'xxxxxxxxxx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2679o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2679 rows=' rows;
else do; set h2679o; if not missing(actual) and abs(actual-(19))<=1e-9*max(1,abs(19)) then put 'ROUND6_PASS=H2679';
else put 'ERROR: ROUND6_FAIL=H2679 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2679:; quit;
