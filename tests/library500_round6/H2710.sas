/* H2710 scan_empty_token_modifier, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2710o; actual=input(scan('a||11|',3,'|','m'),best32.)+missing(scan('a||11|',2,'|','m')); run;

data _null_; if 0 then set h2710o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2710 rows=' rows;
else do; set h2710o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2710';
else put 'ERROR: ROUND6_FAIL=H2710 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2710:; quit;
