/* H2642 prxchange_backreferences, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2642o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr3:42'); actual=3*(text='42-3'); run;

data _null_; if 0 then set h2642o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2642 rows=' rows;
else do; set h2642o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2642';
else put 'ERROR: ROUND6_FAIL=H2642 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2642:; quit;
