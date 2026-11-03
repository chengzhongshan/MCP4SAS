/* H2822 mdy_calendar, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2822o; actual=mdy(3,1,2020); run;

data _null_; if 0 then set h2822o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2822 rows=' rows;
else do; set h2822o; if not missing(actual) and abs(actual-(21975))<=1e-9*max(1,abs(21975)) then put 'ROUND6_PASS=H2822';
else put 'ERROR: ROUND6_FAIL=H2822 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2822:; quit;
