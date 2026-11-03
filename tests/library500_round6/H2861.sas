/* H2861 temp_fexist_lifecycle, N=2; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 2'; run;
data h2861a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2861o; set h2861a; actual=2+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2861o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2861 rows=' rows;
else do; set h2861o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND6_PASS=H2861';
else put 'ERROR: ROUND6_FAIL=H2861 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2861:; quit;
