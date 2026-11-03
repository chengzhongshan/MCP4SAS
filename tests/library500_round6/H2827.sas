/* H2827 mdy_calendar, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2827o; actual=mdy(8,1,2020); run;

data _null_; if 0 then set h2827o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2827 rows=' rows;
else do; set h2827o; if not missing(actual) and abs(actual-(22128))<=1e-9*max(1,abs(22128)) then put 'ROUND6_PASS=H2827';
else put 'ERROR: ROUND6_FAIL=H2827 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2827:; quit;
