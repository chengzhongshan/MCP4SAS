/* H2809 juldate7_calendar, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2809o; actual=juldate7('01JAN2020'd+10); run;

data _null_; if 0 then set h2809o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2809 rows=' rows;
else do; set h2809o; if not missing(actual) and abs(actual-(2020011))<=1e-9*max(1,abs(2020011)) then put 'ROUND6_PASS=H2809';
else put 'ERROR: ROUND6_FAIL=H2809 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2809:; quit;
