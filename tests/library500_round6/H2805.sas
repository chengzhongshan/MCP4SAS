/* H2805 juldate7_calendar, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2805o; actual=juldate7('01JAN2020'd+6); run;

data _null_; if 0 then set h2805o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2805 rows=' rows;
else do; set h2805o; if not missing(actual) and abs(actual-(2020007))<=1e-9*max(1,abs(2020007)) then put 'ROUND6_PASS=H2805';
else put 'ERROR: ROUND6_FAIL=H2805 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2805:; quit;
