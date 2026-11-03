/* H2695 countw_empty_tokens, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2695o; actual=6+countw('a||6|','|','m'); run;

data _null_; if 0 then set h2695o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2695 rows=' rows;
else do; set h2695o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2695';
else put 'ERROR: ROUND6_FAIL=H2695 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2695:; quit;
