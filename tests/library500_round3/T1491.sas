/* T1491 fdelete_owned_temp_file, N=2; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 2'; run;
data t1491o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=2+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1491o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1491 rows=' rows;
else do; set t1491o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1491';
else put 'ERROR: ROUND3_FAIL=T1491 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1491:; quit;
