/* H2801 juldate7_calendar, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2801o; actual=juldate7('01JAN2020'd+2); run;

data _null_; if 0 then set h2801o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2801 rows=' rows;
else do; set h2801o; if not missing(actual) and abs(actual-(2020003))<=1e-9*max(1,abs(2020003)) then put 'ROUND6_PASS=H2801';
else put 'ERROR: ROUND6_FAIL=H2801 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2801:; quit;
