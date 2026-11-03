/* H2707 scan_empty_token_modifier, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2707o; actual=input(scan('a||8|',3,'|','m'),best32.)+missing(scan('a||8|',2,'|','m')); run;

data _null_; if 0 then set h2707o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2707 rows=' rows;
else do; set h2707o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2707';
else put 'ERROR: ROUND6_FAIL=H2707 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2707:; quit;
