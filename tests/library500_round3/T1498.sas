/* T1498 fdelete_owned_temp_file, N=9; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 9'; run;
data t1498o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=9+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1498o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1498 rows=' rows;
else do; set t1498o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1498';
else put 'ERROR: ROUND3_FAIL=T1498 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1498:; quit;
