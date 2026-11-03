/* H2807 juldate7_calendar, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2807o; actual=juldate7('01JAN2020'd+8); run;

data _null_; if 0 then set h2807o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2807 rows=' rows;
else do; set h2807o; if not missing(actual) and abs(actual-(2020009))<=1e-9*max(1,abs(2020009)) then put 'ROUND6_PASS=H2807';
else put 'ERROR: ROUND6_FAIL=H2807 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2807:; quit;
