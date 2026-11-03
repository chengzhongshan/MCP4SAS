/* H2696 countw_empty_tokens, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2696o; actual=7+countw('a||7|','|','m'); run;

data _null_; if 0 then set h2696o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2696 rows=' rows;
else do; set h2696o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2696';
else put 'ERROR: ROUND6_FAIL=H2696 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2696:; quit;
