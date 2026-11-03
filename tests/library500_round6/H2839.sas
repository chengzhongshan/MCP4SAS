/* H2839 hms_time_roundtrip, N=10; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2839o; length text $8; seconds=hms(10,11,12); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2839o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2839 rows=' rows;
else do; set h2839o; if not missing(actual) and abs(actual-(36672))<=1e-9*max(1,abs(36672)) then put 'ROUND6_PASS=H2839';
else put 'ERROR: ROUND6_FAIL=H2839 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2839:; quit;
