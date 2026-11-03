/* H2833 hms_time_roundtrip, N=4; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2833o; length text $8; seconds=hms(4,5,6); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2833o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2833 rows=' rows;
else do; set h2833o; if not missing(actual) and abs(actual-(14706))<=1e-9*max(1,abs(14706)) then put 'ROUND6_PASS=H2833';
else put 'ERROR: ROUND6_FAIL=H2833 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2833:; quit;
