/* H2786 intnx_weekday_skip, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2786o; actual=intnx('weekday','03JAN2020'd,7); run;

data _null_; if 0 then set h2786o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2786 rows=' rows;
else do; set h2786o; if not missing(actual) and abs(actual-(21928))<=1e-9*max(1,abs(21928)) then put 'ROUND6_PASS=H2786';
else put 'ERROR: ROUND6_FAIL=H2786 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2786:; quit;
