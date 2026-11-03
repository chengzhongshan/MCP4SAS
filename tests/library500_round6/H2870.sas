/* H2870 temp_fexist_lifecycle, N=11; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 11'; run;
data h2870a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2870o; set h2870a; actual=11+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2870o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2870 rows=' rows;
else do; set h2870o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND6_PASS=H2870';
else put 'ERROR: ROUND6_FAIL=H2870 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2870:; quit;
