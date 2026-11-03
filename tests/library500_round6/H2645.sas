/* H2645 prxchange_backreferences, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2645o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr6:42'); actual=6*(text='42-6'); run;

data _null_; if 0 then set h2645o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2645 rows=' rows;
else do; set h2645o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2645';
else put 'ERROR: ROUND6_FAIL=H2645 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2645:; quit;
