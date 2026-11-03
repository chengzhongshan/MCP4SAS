/* H2836 hms_time_roundtrip, N=7; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2836o; length text $8; seconds=hms(7,8,9); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2836o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2836 rows=' rows;
else do; set h2836o; if not missing(actual) and abs(actual-(25689))<=1e-9*max(1,abs(25689)) then put 'ROUND6_PASS=H2836';
else put 'ERROR: ROUND6_FAIL=H2836 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2836:; quit;
