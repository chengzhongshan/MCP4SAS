/* H2797 datejul_seven_digit, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2797o; actual=datejul(2020000+8); run;

data _null_; if 0 then set h2797o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2797 rows=' rows;
else do; set h2797o; if not missing(actual) and abs(actual-(21922))<=1e-9*max(1,abs(21922)) then put 'ROUND6_PASS=H2797';
else put 'ERROR: ROUND6_FAIL=H2797 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2797:; quit;
