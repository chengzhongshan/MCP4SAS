/* H2665 prx_case_insensitive_replace, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2665o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene6-gene6'); actual=6*(text='x6-x6'); run;

data _null_; if 0 then set h2665o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2665 rows=' rows;
else do; set h2665o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2665';
else put 'ERROR: ROUND6_FAIL=H2665 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2665:; quit;
