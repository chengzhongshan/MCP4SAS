/* H2664 prx_case_insensitive_replace, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2664o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene5-gene5'); actual=5*(text='x5-x5'); run;

data _null_; if 0 then set h2664o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2664 rows=' rows;
else do; set h2664o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2664';
else put 'ERROR: ROUND6_FAIL=H2664 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2664:; quit;
