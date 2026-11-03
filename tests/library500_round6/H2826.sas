/* H2826 mdy_calendar, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2826o; actual=mdy(7,1,2020); run;

data _null_; if 0 then set h2826o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2826 rows=' rows;
else do; set h2826o; if not missing(actual) and abs(actual-(22097))<=1e-9*max(1,abs(22097)) then put 'ROUND6_PASS=H2826';
else put 'ERROR: ROUND6_FAIL=H2826 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2826:; quit;
