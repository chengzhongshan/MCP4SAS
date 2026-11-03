/* H2663 prx_case_insensitive_replace, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Add quote to separate var list.sas:3 */

data h2663o; length text $40; text=prxchange('s/gene/x/i',-1,'Gene4-gene4'); actual=4*(text='x4-x4'); run;

data _null_; if 0 then set h2663o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2663 rows=' rows;
else do; set h2663o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2663';
else put 'ERROR: ROUND6_FAIL=H2663 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2663:; quit;
