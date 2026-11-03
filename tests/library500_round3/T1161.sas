/* T1161 format_assignment_metadata, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1161a; value=2; format value z8.; run;
proc contents data=t1161a out=t1161b noprint; run;
data t1161o; set t1161b; actual=2+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1161o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1161 rows=' rows;
else do; set t1161o; if not missing(actual) and abs(actual-(20))<=1e-10*max(1,abs(20)) then put 'ROUND3_PASS=T1161';
else put 'ERROR: ROUND3_FAIL=T1161 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1161:; quit;
