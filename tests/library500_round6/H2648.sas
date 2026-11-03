/* H2648 prxchange_backreferences, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2648o; length text $40; text=prxchange('s/^chr([0-9]+):([0-9]+)$/\2-\1/',1,'chr9:42'); actual=9*(text='42-9'); run;

data _null_; if 0 then set h2648o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2648 rows=' rows;
else do; set h2648o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2648';
else put 'ERROR: ROUND6_FAIL=H2648 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2648:; quit;
