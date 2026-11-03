/* H2823 mdy_calendar, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2823o; actual=mdy(4,1,2020); run;

data _null_; if 0 then set h2823o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2823 rows=' rows;
else do; set h2823o; if not missing(actual) and abs(actual-(22006))<=1e-9*max(1,abs(22006)) then put 'ROUND6_PASS=H2823';
else put 'ERROR: ROUND6_FAIL=H2823 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2823:; quit;
