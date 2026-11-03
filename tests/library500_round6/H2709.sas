/* H2709 scan_empty_token_modifier, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2709o; actual=input(scan('a||10|',3,'|','m'),best32.)+missing(scan('a||10|',2,'|','m')); run;

data _null_; if 0 then set h2709o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2709 rows=' rows;
else do; set h2709o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2709';
else put 'ERROR: ROUND6_FAIL=H2709 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2709:; quit;
