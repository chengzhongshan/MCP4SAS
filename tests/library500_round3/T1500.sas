/* T1500 fdelete_owned_temp_file, N=11; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 11'; run;
data t1500o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=11+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1500o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1500 rows=' rows;
else do; set t1500o; if not missing(actual) and abs(actual-(13))<=1e-10*max(1,abs(13)) then put 'ROUND3_PASS=T1500';
else put 'ERROR: ROUND3_FAIL=T1500 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1500:; quit;
