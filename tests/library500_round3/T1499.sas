/* T1499 fdelete_owned_temp_file, N=10; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 10'; run;
data t1499o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=10+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1499o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1499 rows=' rows;
else do; set t1499o; if not missing(actual) and abs(actual-(12))<=1e-10*max(1,abs(12)) then put 'ROUND3_PASS=T1499';
else put 'ERROR: ROUND3_FAIL=T1499 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1499:; quit;
