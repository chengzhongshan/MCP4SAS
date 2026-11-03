/* H2791 datejul_seven_digit, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2791o; actual=datejul(2020000+2); run;

data _null_; if 0 then set h2791o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2791 rows=' rows;
else do; set h2791o; if not missing(actual) and abs(actual-(21916))<=1e-9*max(1,abs(21916)) then put 'ROUND6_PASS=H2791';
else put 'ERROR: ROUND6_FAIL=H2791 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2791:; quit;
