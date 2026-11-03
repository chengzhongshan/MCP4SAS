/* T1471 fopen_fread_fget, N=2; source: SAS-Useful-Codes/Macros/PExFinS_macros/Utilities/PExFinS_SAS_Macros - Copy.sas:2558 */

filename rtemp temp;
data _null_; file rtemp; do x=1 to 2; put x; end; run;
data t1471o; length line $100; fid=fopen('rtemp','i'); actual=0;
if fid>0 then do; do while(fread(fid)=0); rc=fget(fid,line); actual=actual+input(line,best32.); end; rc=fclose(fid); end;
else actual=.; output; stop; run;
filename rtemp clear;

data _null_; if 0 then set t1471o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1471 rows=' rows;
else do; set t1471o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1471';
else put 'ERROR: ROUND3_FAIL=T1471 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1471:; quit;
