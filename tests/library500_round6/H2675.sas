/* H2675 prx_limit_one_replacement, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2675o; length text $40; text=prxchange('s/x/y/',1,'xxxxxx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2675o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2675 rows=' rows;
else do; set h2675o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND6_PASS=H2675';
else put 'ERROR: ROUND6_FAIL=H2675 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2675:; quit;
