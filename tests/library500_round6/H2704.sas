/* H2704 scan_empty_token_modifier, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2704o; actual=input(scan('a||5|',3,'|','m'),best32.)+missing(scan('a||5|',2,'|','m')); run;

data _null_; if 0 then set h2704o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2704 rows=' rows;
else do; set h2704o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2704';
else put 'ERROR: ROUND6_FAIL=H2704 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2704:; quit;
