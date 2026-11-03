/* H2647 prxchange_backreferences, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2647o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr8:42'); actual=8*(text='42-8'); run;

data _null_; if 0 then set h2647o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2647 rows=' rows;
else do; set h2647o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2647';
else put 'ERROR: ROUND6_FAIL=H2647 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2647:; quit;
