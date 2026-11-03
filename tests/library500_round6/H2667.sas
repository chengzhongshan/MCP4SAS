/* H2667 prx_case_insensitive_replace, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2667o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene8-gene8'); actual=8*(text='x8-x8'); run;

data _null_; if 0 then set h2667o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2667 rows=' rows;
else do; set h2667o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2667';
else put 'ERROR: ROUND6_FAIL=H2667 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2667:; quit;
