/* H2680 prx_limit_one_replacement, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2680o; length text $40; text=prxchange('s/x/y/',1,'xxxxxxxxxxx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2680o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2680 rows=' rows;
else do; set h2680o; if not missing(actual) and abs(actual-(20))<=1e-9*max(1,abs(20)) then put 'ROUND6_PASS=H2680';
else put 'ERROR: ROUND6_FAIL=H2680 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2680:; quit;
