/* H2790 intnx_weekday_skip, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2790o; actual=intnx('weekday','03JAN2020'd,11); run;

data _null_; if 0 then set h2790o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2790 rows=' rows;
else do; set h2790o; if not missing(actual) and abs(actual-(21934))<=1e-9*max(1,abs(21934)) then put 'ROUND6_PASS=H2790';
else put 'ERROR: ROUND6_FAIL=H2790 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2790:; quit;
