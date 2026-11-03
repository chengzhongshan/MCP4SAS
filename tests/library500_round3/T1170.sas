/* T1170 format_assignment_metadata, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1170a; value=11; format value z8.; run;
proc contents data=t1170a out=t1170b noprint; run;
data t1170o; set t1170b; actual=11+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1170o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1170 rows=' rows;
else do; set t1170o; if not missing(actual) and abs(actual-(29))<=1e-10*max(1,abs(29)) then put 'ROUND3_PASS=T1170';
else put 'ERROR: ROUND3_FAIL=T1170 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1170:; quit;
