/* H2832 hms_time_roundtrip, N=3; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2832o; length text $8; seconds=hms(3,4,5); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2832o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2832 rows=' rows;
else do; set h2832o; if not missing(actual) and abs(actual-(11045))<=1e-9*max(1,abs(11045)) then put 'ROUND6_PASS=H2832';
else put 'ERROR: ROUND6_FAIL=H2832 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2832:; quit;
