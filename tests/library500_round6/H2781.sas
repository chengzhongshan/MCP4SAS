/* H2781 intnx_weekday_skip, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2781o; actual=intnx('weekday','03JAN2020'd,2); run;

data _null_; if 0 then set h2781o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2781 rows=' rows;
else do; set h2781o; if not missing(actual) and abs(actual-(21921))<=1e-9*max(1,abs(21921)) then put 'ROUND6_PASS=H2781';
else put 'ERROR: ROUND6_FAIL=H2781 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2781:; quit;
