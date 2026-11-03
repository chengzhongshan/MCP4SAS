/* H2806 juldate7_calendar, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2806o; actual=juldate7('01JAN2020'd+7); run;

data _null_; if 0 then set h2806o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2806 rows=' rows;
else do; set h2806o; if not missing(actual) and abs(actual-(2020008))<=1e-9*max(1,abs(2020008)) then put 'ROUND6_PASS=H2806';
else put 'ERROR: ROUND6_FAIL=H2806 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2806:; quit;
