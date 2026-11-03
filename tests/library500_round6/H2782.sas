/* H2782 intnx_weekday_skip, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2782o; actual=intnx('weekday','03JAN2020'd,3); run;

data _null_; if 0 then set h2782o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2782 rows=' rows;
else do; set h2782o; if not missing(actual) and abs(actual-(21922))<=1e-9*max(1,abs(21922)) then put 'ROUND6_PASS=H2782';
else put 'ERROR: ROUND6_FAIL=H2782 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2782:; quit;
