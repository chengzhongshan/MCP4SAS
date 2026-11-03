/* H2646 prxchange_backreferences, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2646o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr7:42'); actual=7*(text='42-7'); run;

data _null_; if 0 then set h2646o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2646 rows=' rows;
else do; set h2646o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2646';
else put 'ERROR: ROUND6_FAIL=H2646 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2646:; quit;
