/* T1497 fdelete_owned_temp_file, N=8; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 8'; run;
data t1497o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=8+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1497o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1497 rows=' rows;
else do; set t1497o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1497';
else put 'ERROR: ROUND3_FAIL=T1497 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1497:; quit;
