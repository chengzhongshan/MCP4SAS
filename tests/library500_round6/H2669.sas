/* H2669 prx_case_insensitive_replace, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2669o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene10-gene10'); actual=10*(text='x10-x10'); run;

data _null_; if 0 then set h2669o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2669 rows=' rows;
else do; set h2669o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2669';
else put 'ERROR: ROUND6_FAIL=H2669 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2669:; quit;
