/* H2800 datejul_seven_digit, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2800o; actual=datejul(2020000+11); run;

data _null_; if 0 then set h2800o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2800 rows=' rows;
else do; set h2800o; if not missing(actual) and abs(actual-(21925))<=1e-9*max(1,abs(21925)) then put 'ROUND6_PASS=H2800';
else put 'ERROR: ROUND6_FAIL=H2800 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2800:; quit;
