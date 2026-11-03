/* H2662 prx_case_insensitive_replace, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2662o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene3-gene3'); actual=3*(text='x3-x3'); run;

data _null_; if 0 then set h2662o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2662 rows=' rows;
else do; set h2662o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2662';
else put 'ERROR: ROUND6_FAIL=H2662 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2662:; quit;
