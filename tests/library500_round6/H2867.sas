/* H2867 temp_fexist_lifecycle, N=8; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 8'; run;
data h2867a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2867o; set h2867a; actual=8+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2867o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2867 rows=' rows;
else do; set h2867o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND6_PASS=H2867';
else put 'ERROR: ROUND6_FAIL=H2867 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2867:; quit;
