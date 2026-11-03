/* H2830 mdy_calendar, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2830o; actual=mdy(11,1,2020); run;

data _null_; if 0 then set h2830o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2830 rows=' rows;
else do; set h2830o; if not missing(actual) and abs(actual-(22220))<=1e-9*max(1,abs(22220)) then put 'ROUND6_PASS=H2830';
else put 'ERROR: ROUND6_FAIL=H2830 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2830:; quit;
