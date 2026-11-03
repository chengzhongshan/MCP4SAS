/* H2835 hms_time_roundtrip, N=6; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2835o; length text $8; seconds=hms(6,7,8); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2835o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2835 rows=' rows;
else do; set h2835o; if not missing(actual) and abs(actual-(22028))<=1e-9*max(1,abs(22028)) then put 'ROUND6_PASS=H2835';
else put 'ERROR: ROUND6_FAIL=H2835 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2835:; quit;
