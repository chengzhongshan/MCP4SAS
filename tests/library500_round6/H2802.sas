/* H2802 juldate7_calendar, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2802o; actual=juldate7('01JAN2020'd+3); run;

data _null_; if 0 then set h2802o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2802 rows=' rows;
else do; set h2802o; if not missing(actual) and abs(actual-(2020004))<=1e-9*max(1,abs(2020004)) then put 'ROUND6_PASS=H2802';
else put 'ERROR: ROUND6_FAIL=H2802 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2802:; quit;
