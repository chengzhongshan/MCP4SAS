/* T1495 fdelete_owned_temp_file, N=6; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 6'; run;
data t1495o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=6+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1495o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1495 rows=' rows;
else do; set t1495o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1495';
else put 'ERROR: ROUND3_FAIL=T1495 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1495:; quit;
