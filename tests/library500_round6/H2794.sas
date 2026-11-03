/* H2794 datejul_seven_digit, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2794o; actual=datejul(2020000+5); run;

data _null_; if 0 then set h2794o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2794 rows=' rows;
else do; set h2794o; if not missing(actual) and abs(actual-(21919))<=1e-9*max(1,abs(21919)) then put 'ROUND6_PASS=H2794';
else put 'ERROR: ROUND6_FAIL=H2794 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2794:; quit;
