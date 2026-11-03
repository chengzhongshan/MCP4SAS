/* H2796 datejul_seven_digit, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2796o; actual=datejul(2020000+7); run;

data _null_; if 0 then set h2796o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2796 rows=' rows;
else do; set h2796o; if not missing(actual) and abs(actual-(21921))<=1e-9*max(1,abs(21921)) then put 'ROUND6_PASS=H2796';
else put 'ERROR: ROUND6_FAIL=H2796 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2796:; quit;
