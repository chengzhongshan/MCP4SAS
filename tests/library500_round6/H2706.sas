/* H2706 scan_empty_token_modifier, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2706o; actual=input(scan('a||7|',3,'|','m'),best32.)+missing(scan('a||7|',2,'|','m')); run;

data _null_; if 0 then set h2706o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2706 rows=' rows;
else do; set h2706o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2706';
else put 'ERROR: ROUND6_FAIL=H2706 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2706:; quit;
