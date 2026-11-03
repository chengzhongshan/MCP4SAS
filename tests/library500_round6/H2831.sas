/* H2831 hms_time_roundtrip, N=2; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2831o; length text $8; seconds=hms(2,3,4); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2831o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2831 rows=' rows;
else do; set h2831o; if not missing(actual) and abs(actual-(7384))<=1e-9*max(1,abs(7384)) then put 'ROUND6_PASS=H2831';
else put 'ERROR: ROUND6_FAIL=H2831 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2831:; quit;
