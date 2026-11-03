/* H2785 intnx_weekday_skip, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2785o; actual=intnx('weekday','03JAN2020'd,6); run;

data _null_; if 0 then set h2785o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2785 rows=' rows;
else do; set h2785o; if not missing(actual) and abs(actual-(21927))<=1e-9*max(1,abs(21927)) then put 'ROUND6_PASS=H2785';
else put 'ERROR: ROUND6_FAIL=H2785 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2785:; quit;
