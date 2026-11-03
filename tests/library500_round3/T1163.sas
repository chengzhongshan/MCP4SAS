/* T1163 format_assignment_metadata, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1163a; value=4; format value z8.; run;
proc contents data=t1163a out=t1163b noprint; run;
data t1163o; set t1163b; actual=4+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1163o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1163 rows=' rows;
else do; set t1163o; if not missing(actual) and abs(actual-(22))<=1e-10*max(1,abs(22)) then put 'ROUND3_PASS=T1163';
else put 'ERROR: ROUND3_FAIL=T1163 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1163:; quit;
