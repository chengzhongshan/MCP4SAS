/* H2688 findw_case_insensitive, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2688o; actual=9+findw('gene9 X','GENE9',' ','i'); run;

data _null_; if 0 then set h2688o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2688 rows=' rows;
else do; set h2688o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2688';
else put 'ERROR: ROUND6_FAIL=H2688 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2688:; quit;
