/* H2824 mdy_calendar, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2824o; actual=mdy(5,1,2020); run;

data _null_; if 0 then set h2824o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2824 rows=' rows;
else do; set h2824o; if not missing(actual) and abs(actual-(22036))<=1e-9*max(1,abs(22036)) then put 'ROUND6_PASS=H2824';
else put 'ERROR: ROUND6_FAIL=H2824 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2824:; quit;
