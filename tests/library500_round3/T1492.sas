/* T1492 fdelete_owned_temp_file, N=3; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 3'; run;
data t1492o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=3+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1492o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1492 rows=' rows;
else do; set t1492o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1492';
else put 'ERROR: ROUND3_FAIL=T1492 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1492:; quit;
