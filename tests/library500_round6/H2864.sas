/* H2864 temp_fexist_lifecycle, N=5; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 5'; run;
data h2864a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2864o; set h2864a; actual=5+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2864o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2864 rows=' rows;
else do; set h2864o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND6_PASS=H2864';
else put 'ERROR: ROUND6_FAIL=H2864 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2864:; quit;
