/* H2866 temp_fexist_lifecycle, N=7; source: SAS-Useful-Codes/Macros/Create_Dir.sas:6 */

filename rtemp temp;
data _null_; file rtemp; put 'owned 7'; run;
data h2866a; length path $512; path=pathname('rtemp'); present=fexist('rtemp'); run;
filename rtemp clear;
data h2866o; set h2866a; actual=7+present+(fileexist(path)=0); run;

data _null_; if 0 then set h2866o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND6_ROWS=H2866 rows=' rows;
else do; set h2866o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND6_PASS=H2866';
else put 'ERROR: ROUND6_FAIL=H2866 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete h2866:; quit;
