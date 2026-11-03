/* H2837 hms_time_roundtrip, N=8; source: SAS-Useful-Codes/Macros/DIRLISTWIN.sas:150 */

data h2837o; length text $8; seconds=hms(8,9,10); text=put(seconds,time8.); actual=input(text,time8.); run;

data _null_; if 0 then set h2837o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2837 rows=' rows;
else do; set h2837o; if not missing(actual) and abs(actual-(29350))<=1e-9*max(1,abs(29350)) then put 'ROUND6_PASS=H2837';
else put 'ERROR: ROUND6_FAIL=H2837 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2837:; quit;
