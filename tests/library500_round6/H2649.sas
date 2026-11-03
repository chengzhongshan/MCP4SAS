/* H2649 prxchange_backreferences, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2649o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr10:42'); actual=10*(text='42-10'); run;

data _null_; if 0 then set h2649o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2649 rows=' rows;
else do; set h2649o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2649';
else put 'ERROR: ROUND6_FAIL=H2649 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2649:; quit;
