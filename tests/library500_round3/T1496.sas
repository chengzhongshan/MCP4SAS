/* T1496 fdelete_owned_temp_file, N=7; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 7'; run;
data t1496o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=7+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1496o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1496 rows=' rows;
else do; set t1496o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1496';
else put 'ERROR: ROUND3_FAIL=T1496 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1496:; quit;
