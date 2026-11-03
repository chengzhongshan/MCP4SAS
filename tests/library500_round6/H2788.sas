/* H2788 intnx_weekday_skip, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2788o; actual=intnx('weekday','03JAN2020'd,9); run;

data _null_; if 0 then set h2788o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2788 rows=' rows;
else do; set h2788o; if not missing(actual) and abs(actual-(21930))<=1e-9*max(1,abs(21930)) then put 'ROUND6_PASS=H2788';
else put 'ERROR: ROUND6_FAIL=H2788 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2788:; quit;
