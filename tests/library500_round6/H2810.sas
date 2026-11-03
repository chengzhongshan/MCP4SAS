/* H2810 juldate7_calendar, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2810o; actual=juldate7('01JAN2020'd+11); run;

data _null_; if 0 then set h2810o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2810 rows=' rows;
else do; set h2810o; if not missing(actual) and abs(actual-(2020012))<=1e-9*max(1,abs(2020012)) then put 'ROUND6_PASS=H2810';
else put 'ERROR: ROUND6_FAIL=H2810 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2810:; quit;
