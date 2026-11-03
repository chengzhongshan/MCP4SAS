/* H2838 hms_time_roundtrip, N=9; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2838o; length text $8; seconds=hms(9,10,11); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2838o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2838 rows=' rows;
else do; set h2838o; if not missing(actual) and abs(actual-(33011))<=1e-9*max(1,abs(33011)) then put 'ROUND6_PASS=H2838';
else put 'ERROR: ROUND6_FAIL=H2838 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2838:; quit;
