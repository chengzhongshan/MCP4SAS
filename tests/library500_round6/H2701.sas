/* H2701 scan_empty_token_modifier, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2701o; actual=input(scan('a||2|',3,'|','m'),best32.)+missing(scan('a||2|',2,'|','m')); run;

data _null_; if 0 then set h2701o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2701 rows=' rows;
else do; set h2701o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND6_PASS=H2701';
else put 'ERROR: ROUND6_FAIL=H2701 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2701:; quit;
