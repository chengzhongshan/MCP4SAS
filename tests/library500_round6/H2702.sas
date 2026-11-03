/* H2702 scan_empty_token_modifier, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2702o; actual=input(scan('a||3|',3,'|','m'),best32.)+missing(scan('a||3|',2,'|','m')); run;

data _null_; if 0 then set h2702o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2702 rows=' rows;
else do; set h2702o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2702';
else put 'ERROR: ROUND6_FAIL=H2702 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2702:; quit;
