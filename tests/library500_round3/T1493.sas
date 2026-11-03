/* T1493 fdelete_owned_temp_file, N=4; source: SAS-Useful-Codes/Macros/Del_Dir_Recursive.sas:75 */

filename rtemp temp;
data _null_; file rtemp; put 'owned test 4'; run;
data t1493o; length path $512; path=pathname('rtemp'); rc=fdelete('rtemp'); actual=4+(rc=0)+(fileexist(path)=0); run;
filename rtemp clear;

data _null_; if 0 then set t1493o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1493 rows=' rows;
else do; set t1493o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1493';
else put 'ERROR: ROUND3_FAIL=T1493 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1493:; quit;
