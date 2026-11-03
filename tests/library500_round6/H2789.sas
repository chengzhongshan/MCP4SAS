/* H2789 intnx_weekday_skip, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2789o; actual=intnx('weekday','03JAN2020'd,10); run;

data _null_; if 0 then set h2789o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2789 rows=' rows;
else do; set h2789o; if not missing(actual) and abs(actual-(21931))<=1e-9*max(1,abs(21931)) then put 'ROUND6_PASS=H2789';
else put 'ERROR: ROUND6_FAIL=H2789 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2789:; quit;
