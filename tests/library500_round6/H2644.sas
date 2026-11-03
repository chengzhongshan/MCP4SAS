/* H2644 prxchange_backreferences, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2644o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr5:42'); actual=5*(text='42-5'); run;

data _null_; if 0 then set h2644o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2644 rows=' rows;
else do; set h2644o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2644';
else put 'ERROR: ROUND6_FAIL=H2644 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2644:; quit;
