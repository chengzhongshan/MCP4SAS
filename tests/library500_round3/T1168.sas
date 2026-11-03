/* T1168 format_assignment_metadata, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1168a; value=9; format value z8.; run;
proc contents data=t1168a out=t1168b noprint; run;
data t1168o; set t1168b; actual=9+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1168o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1168 rows=' rows;
else do; set t1168o; if not missing(actual) and abs(actual-(27))<=1e-10*max(1,abs(27)) then put 'ROUND3_PASS=T1168';
else put 'ERROR: ROUND3_FAIL=T1168 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1168:; quit;
