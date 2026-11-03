/* H2840 hms_time_roundtrip, N=11; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2840o; length text $8; seconds=hms(11,12,13); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2840o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2840 rows=' rows;
else do; set h2840o; if not missing(actual) and abs(actual-(40333))<=1e-9*max(1,abs(40333)) then put 'ROUND6_PASS=H2840';
else put 'ERROR: ROUND6_FAIL=H2840 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2840:; quit;
