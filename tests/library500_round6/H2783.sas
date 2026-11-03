/* H2783 intnx_weekday_skip, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2783o; actual=intnx('weekday','03JAN2020'd,4); run;

data _null_; if 0 then set h2783o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2783 rows=' rows;
else do; set h2783o; if not missing(actual) and abs(actual-(21923))<=1e-9*max(1,abs(21923)) then put 'ROUND6_PASS=H2783';
else put 'ERROR: ROUND6_FAIL=H2783 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2783:; quit;
