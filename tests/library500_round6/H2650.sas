/* H2650 prxchange_backreferences, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2650o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr11:42'); actual=11*(text='42-11'); run;

data _null_; if 0 then set h2650o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2650 rows=' rows;
else do; set h2650o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2650';
else put 'ERROR: ROUND6_FAIL=H2650 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2650:; quit;
