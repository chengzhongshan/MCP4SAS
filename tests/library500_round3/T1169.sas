/* T1169 format_assignment_metadata, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1169a; value=10; format value z8.; run;
proc contents data=t1169a out=t1169b noprint; run;
data t1169o; set t1169b; actual=10+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1169o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1169 rows=' rows;
else do; set t1169o; if not missing(actual) and abs(actual-(28))<=1e-10*max(1,abs(28)) then put 'ROUND3_PASS=T1169';
else put 'ERROR: ROUND3_FAIL=T1169 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1169:; quit;
