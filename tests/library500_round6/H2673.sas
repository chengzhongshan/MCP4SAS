/* H2673 prx_limit_one_replacement, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2673o; length text $40; text=prxchange('s/x/y/',1,'xxxx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2673o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2673 rows=' rows;
else do; set h2673o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND6_PASS=H2673';
else put 'ERROR: ROUND6_FAIL=H2673 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2673:; quit;
