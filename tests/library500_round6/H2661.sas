/* H2661 prx_case_insensitive_replace, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2661o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene2-gene2'); actual=2*(text='x2-x2'); run;

data _null_; if 0 then set h2661o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2661 rows=' rows;
else do; set h2661o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND6_PASS=H2661';
else put 'ERROR: ROUND6_FAIL=H2661 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2661:; quit;
