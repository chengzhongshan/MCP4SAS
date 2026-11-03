/* T1162 format_assignment_metadata, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1162a; value=3; format value z8.; run;
proc contents data=t1162a out=t1162b noprint; run;
data t1162o; set t1162b; actual=3+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1162o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1162 rows=' rows;
else do; set t1162o; if not missing(actual) and abs(actual-(21))<=1e-10*max(1,abs(21)) then put 'ROUND3_PASS=T1162';
else put 'ERROR: ROUND3_FAIL=T1162 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1162:; quit;
