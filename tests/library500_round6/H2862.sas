/* H2862 temp_fexist_lifecycle, N=3; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 3'; run;
data h2862a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2862o; set h2862a; actual=3+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2862o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2862 rows=' rows;
else do; set h2862o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND6_PASS=H2862';
else put 'ERROR: ROUND6_FAIL=H2862 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2862:; quit;
