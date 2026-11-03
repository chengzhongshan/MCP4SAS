/* H2821 mdy_calendar, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2821o; actual=mdy(2,1,2020); run;

data _null_; if 0 then set h2821o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2821 rows=' rows;
else do; set h2821o; if not missing(actual) and abs(actual-(21946))<=1e-9*max(1,abs(21946)) then put 'ROUND6_PASS=H2821';
else put 'ERROR: ROUND6_FAIL=H2821 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2821:; quit;
