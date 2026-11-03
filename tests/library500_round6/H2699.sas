/* H2699 countw_empty_tokens, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2699o; actual=10+countw('a||10|','|','m'); run;

data _null_; if 0 then set h2699o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2699 rows=' rows;
else do; set h2699o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND6_PASS=H2699';
else put 'ERROR: ROUND6_FAIL=H2699 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2699:; quit;
