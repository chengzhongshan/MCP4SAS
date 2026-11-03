/* H2787 intnx_weekday_skip, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2787o; actual=intnx('weekday','03JAN2020'd,8); run;

data _null_; if 0 then set h2787o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2787 rows=' rows;
else do; set h2787o; if not missing(actual) and abs(actual-(21929))<=1e-9*max(1,abs(21929)) then put 'ROUND6_PASS=H2787';
else put 'ERROR: ROUND6_FAIL=H2787 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2787:; quit;
