/* H2792 datejul_seven_digit, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2792o; actual=datejul(2020000+3); run;

data _null_; if 0 then set h2792o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2792 rows=' rows;
else do; set h2792o; if not missing(actual) and abs(actual-(21917))<=1e-9*max(1,abs(21917)) then put 'ROUND6_PASS=H2792';
else put 'ERROR: ROUND6_FAIL=H2792 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2792:; quit;
