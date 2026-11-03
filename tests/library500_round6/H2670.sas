/* H2670 prx_case_insensitive_replace, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2670o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene11-gene11'); actual=11*(text='x11-x11'); run;

data _null_; if 0 then set h2670o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2670 rows=' rows;
else do; set h2670o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2670';
else put 'ERROR: ROUND6_FAIL=H2670 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2670:; quit;
