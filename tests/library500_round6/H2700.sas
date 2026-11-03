/* H2700 countw_empty_tokens, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2700o; actual=11+countw('a||11|','|','m'); run;

data _null_; if 0 then set h2700o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2700 rows=' rows;
else do; set h2700o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND6_PASS=H2700';
else put 'ERROR: ROUND6_FAIL=H2700 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2700:; quit;
