/* H2668 prx_case_insensitive_replace, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2668o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene9-gene9'); actual=9*(text='x9-x9'); run;

data _null_; if 0 then set h2668o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2668 rows=' rows;
else do; set h2668o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2668';
else put 'ERROR: ROUND6_FAIL=H2668 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2668:; quit;
