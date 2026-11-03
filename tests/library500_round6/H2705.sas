/* H2705 scan_empty_token_modifier, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2705o; actual=input(scan('a||6|',3,'|','m'),best32.)+missing(scan('a||6|',2,'|','m')); run;

data _null_; if 0 then set h2705o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2705 rows=' rows;
else do; set h2705o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2705';
else put 'ERROR: ROUND6_FAIL=H2705 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2705:; quit;
