/* H2868 temp_fexist_lifecycle, N=9; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 9'; run;
data h2868a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2868o; set h2868a; actual=9+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2868o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2868 rows=' rows;
else do; set h2868o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND6_PASS=H2868';
else put 'ERROR: ROUND6_FAIL=H2868 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2868:; quit;
