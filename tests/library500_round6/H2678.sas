/* H2678 prx_limit_one_replacement, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2678o; length text $40; text=prxchange('s/x/y/',1,'xxxxxxxxx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2678o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2678 rows=' rows;
else do; set h2678o; if not missing(actual) and abs(actual-(18))<=1e-9*max(1,abs(18)) then put 'ROUND6_PASS=H2678';
else put 'ERROR: ROUND6_FAIL=H2678 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2678:; quit;
