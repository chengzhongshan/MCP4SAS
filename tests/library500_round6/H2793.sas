/* H2793 datejul_seven_digit, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2793o; actual=datejul(2020000+4); run;

data _null_; if 0 then set h2793o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2793 rows=' rows;
else do; set h2793o; if not missing(actual) and abs(actual-(21918))<=1e-9*max(1,abs(21918)) then put 'ROUND6_PASS=H2793';
else put 'ERROR: ROUND6_FAIL=H2793 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2793:; quit;
