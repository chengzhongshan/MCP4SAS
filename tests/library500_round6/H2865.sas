/* H2865 temp_fexist_lifecycle, N=6; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 6'; run;
data h2865a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2865o; set h2865a; actual=6+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2865o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2865 rows=' rows;
else do; set h2865o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND6_PASS=H2865';
else put 'ERROR: ROUND6_FAIL=H2865 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2865:; quit;
