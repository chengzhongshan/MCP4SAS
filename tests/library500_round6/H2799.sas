/* H2799 datejul_seven_digit, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2799o; actual=datejul(2020000+10); run;

data _null_; if 0 then set h2799o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2799 rows=' rows;
else do; set h2799o; if not missing(actual) and abs(actual-(21924))<=1e-9*max(1,abs(21924)) then put 'ROUND6_PASS=H2799';
else put 'ERROR: ROUND6_FAIL=H2799 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2799:; quit;
