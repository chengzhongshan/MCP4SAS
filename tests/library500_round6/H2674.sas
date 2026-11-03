/* H2674 prx_limit_one_replacement, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2674o; length text $40; text=prxchange('s/x/y/',1,'xxxxx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2674o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2674 rows=' rows;
else do; set h2674o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND6_PASS=H2674';
else put 'ERROR: ROUND6_FAIL=H2674 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2674:; quit;
