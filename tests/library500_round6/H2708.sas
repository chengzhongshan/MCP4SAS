/* H2708 scan_empty_token_modifier, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Demo of using prxchange to update macro var and create new var for use.sas:16 */

data h2708o; actual=input(scan('a||9|',3,'|','m'),best32.)+missing(scan('a||9|',2,'|','m')); run;

data _null_; if 0 then set h2708o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2708 rows=' rows;
else do; set h2708o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2708';
else put 'ERROR: ROUND6_FAIL=H2708 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2708:; quit;
