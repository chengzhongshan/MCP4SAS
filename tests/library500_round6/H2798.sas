/* H2798 datejul_seven_digit, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2798o; actual=datejul(2020000+9); run;

data _null_; if 0 then set h2798o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2798 rows=' rows;
else do; set h2798o; if not missing(actual) and abs(actual-(21923))<=1e-9*max(1,abs(21923)) then put 'ROUND6_PASS=H2798';
else put 'ERROR: ROUND6_FAIL=H2798 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2798:; quit;
