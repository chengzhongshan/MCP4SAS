/* H2671 prx_limit_one_replacement, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2671o; length text $40; text=prxchange('s/x/y/',1,'xx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2671o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2671 rows=' rows;
else do; set h2671o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2671';
else put 'ERROR: ROUND6_FAIL=H2671 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2671:; quit;
