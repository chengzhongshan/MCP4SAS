/* H2863 temp_fexist_lifecycle, N=4; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 4'; run;
data h2863a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2863o; set h2863a; actual=4+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2863o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2863 rows=' rows;
else do; set h2863o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND6_PASS=H2863';
else put 'ERROR: ROUND6_FAIL=H2863 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2863:; quit;
