/* T1165 format_assignment_metadata, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1165a; value=6; format value z8.; run;
proc contents data=t1165a out=t1165b noprint; run;
data t1165o; set t1165b; actual=6+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1165o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1165 rows=' rows;
else do; set t1165o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND3_PASS=T1165';
else put 'ERROR: ROUND3_FAIL=T1165 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1165:; quit;
