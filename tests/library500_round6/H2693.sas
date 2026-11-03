/* H2693 countw_empty_tokens, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2693o; actual=4+countw('a||4|','|','m'); run;

data _null_; if 0 then set h2693o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2693 rows=' rows;
else do; set h2693o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2693';
else put 'ERROR: ROUND6_FAIL=H2693 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2693:; quit;
