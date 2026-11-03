/* H2829 mdy_calendar, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2829o; actual=mdy(10,1,2020); run;

data _null_; if 0 then set h2829o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2829 rows=' rows;
else do; set h2829o; if not missing(actual) and abs(actual-(22189))<=1e-9*max(1,abs(22189)) then put 'ROUND6_PASS=H2829';
else put 'ERROR: ROUND6_FAIL=H2829 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2829:; quit;
