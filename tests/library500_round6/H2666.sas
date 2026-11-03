/* H2666 prx_case_insensitive_replace, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2666o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene7-gene7'); actual=7*(text='x7-x7'); run;

data _null_; if 0 then set h2666o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2666 rows=' rows;
else do; set h2666o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2666';
else put 'ERROR: ROUND6_FAIL=H2666 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2666:; quit;
