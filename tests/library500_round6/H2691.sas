/* H2691 countw_empty_tokens, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2691o; actual=2+countw('a||2|','|','m'); run;

data _null_; if 0 then set h2691o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2691 rows=' rows;
else do; set h2691o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2691';
else put 'ERROR: ROUND6_FAIL=H2691 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2691:; quit;
