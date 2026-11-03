/* H2804 juldate7_calendar, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2804o; actual=juldate7('01JAN2020'd+5); run;

data _null_; if 0 then set h2804o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2804 rows=' rows;
else do; set h2804o; if not missing(actual) and abs(actual-(2020006))<=1e-9*max(1,abs(2020006)) then put 'ROUND6_PASS=H2804';
else put 'ERROR: ROUND6_FAIL=H2804 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2804:; quit;
