/* H2694 countw_empty_tokens, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2694o; actual=5+countw('a||5|','|','m'); run;

data _null_; if 0 then set h2694o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2694 rows=' rows;
else do; set h2694o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2694';
else put 'ERROR: ROUND6_FAIL=H2694 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2694:; quit;
