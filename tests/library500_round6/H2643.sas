/* H2643 prxchange_backreferences, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2643o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr4:42'); actual=4*(text='42-4'); run;

data _null_; if 0 then set h2643o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2643 rows=' rows;
else do; set h2643o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2643';
else put 'ERROR: ROUND6_FAIL=H2643 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2643:; quit;
