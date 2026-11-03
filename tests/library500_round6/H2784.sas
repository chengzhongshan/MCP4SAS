/* H2784 intnx_weekday_skip, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2784o; actual=intnx('weekday','03JAN2020'd,5); run;

data _null_; if 0 then set h2784o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2784 rows=' rows;
else do; set h2784o; if not missing(actual) and abs(actual-(21924))<=1e-9*max(1,abs(21924)) then put 'ROUND6_PASS=H2784';
else put 'ERROR: ROUND6_FAIL=H2784 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2784:; quit;
