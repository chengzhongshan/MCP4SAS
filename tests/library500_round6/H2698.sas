/* H2698 countw_empty_tokens, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/countc_demo.sas:1 */

data h2698o; actual=9+countw('a||9|','|','m'); run;

data _null_; if 0 then set h2698o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2698 rows=' rows;
else do; set h2698o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND6_PASS=H2698';
else put 'ERROR: ROUND6_FAIL=H2698 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2698:; quit;
