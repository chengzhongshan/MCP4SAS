/* H2808 juldate7_calendar, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2808o; actual=juldate7('01JAN2020'd+9); run;

data _null_; if 0 then set h2808o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2808 rows=' rows;
else do; set h2808o; if not missing(actual) and abs(actual-(2020010))<=1e-9*max(1,abs(2020010)) then put 'ROUND6_PASS=H2808';
else put 'ERROR: ROUND6_FAIL=H2808 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2808:; quit;
