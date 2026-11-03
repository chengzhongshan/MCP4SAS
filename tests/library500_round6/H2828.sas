/* H2828 mdy_calendar, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2828o; actual=mdy(9,1,2020); run;

data _null_; if 0 then set h2828o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2828 rows=' rows;
else do; set h2828o; if not missing(actual) and abs(actual-(22159))<=1e-9*max(1,abs(22159)) then put 'ROUND6_PASS=H2828';
else put 'ERROR: ROUND6_FAIL=H2828 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2828:; quit;
