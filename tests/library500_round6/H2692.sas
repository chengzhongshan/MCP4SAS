/* H2692 countw_empty_tokens, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2692o; actual=3+countw('a||3|','|','m'); run;

data _null_; if 0 then set h2692o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2692 rows=' rows;
else do; set h2692o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2692';
else put 'ERROR: ROUND6_FAIL=H2692 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2692:; quit;
