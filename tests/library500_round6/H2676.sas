/* H2676 prx_limit_one_replacement, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2676o; length text $40; text=prxchange('s/x/y/',1,'xxxxxxx'); actual=10*countc(text,'y')+countc(text,'x'); run;

data _null_; if 0 then set h2676o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2676 rows=' rows;
else do; set h2676o; if not missing(actual) and abs(actual-(16))<=1e-9*max(1,abs(16)) then put 'ROUND6_PASS=H2676';
else put 'ERROR: ROUND6_FAIL=H2676 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2676:; quit;
