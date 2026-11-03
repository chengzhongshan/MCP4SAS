/* H2834 hms_time_roundtrip, N=5; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2834o; length text $8; seconds=hms(5,6,7); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2834o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2834 rows=' rows;
else do; set h2834o; if not missing(actual) and abs(actual-(18367))<=1e-9*max(1,abs(18367)) then put 'ROUND6_PASS=H2834';
else put 'ERROR: ROUND6_FAIL=H2834 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2834:; quit;
