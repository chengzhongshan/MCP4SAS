/* H2869 temp_fexist_lifecycle, N=10; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 10'; run;
data h2869a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2869o; set h2869a; actual=10+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2869o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2869 rows=' rows;
else do; set h2869o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND6_PASS=H2869';
else put 'ERROR: ROUND6_FAIL=H2869 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2869:; quit;
