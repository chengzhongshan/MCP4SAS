/* H2825 mdy_calendar, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2825o; actual=mdy(6,1,2020); run;

data _null_; if 0 then set h2825o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2825 rows=' rows;
else do; set h2825o; if not missing(actual) and abs(actual-(22067))<=1e-9*max(1,abs(22067)) then put 'ROUND6_PASS=H2825';
else put 'ERROR: ROUND6_FAIL=H2825 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2825:; quit;
