/* H2697 countw_empty_tokens, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2697o; actual=8+countw('a||8|','|','m'); run;

data _null_; if 0 then set h2697o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2697 rows=' rows;
else do; set h2697o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2697';
else put 'ERROR: ROUND6_FAIL=H2697 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2697:; quit;
