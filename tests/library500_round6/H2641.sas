/* H2641 prxchange_backreferences, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2641o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr2:42'); actual=2*(text='42-2'); run;

data _null_; if 0 then set h2641o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2641 rows=' rows;
else do; set h2641o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND6_PASS=H2641';
else put 'ERROR: ROUND6_FAIL=H2641 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2641:; quit;
