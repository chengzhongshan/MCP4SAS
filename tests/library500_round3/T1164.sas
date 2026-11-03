/* T1164 format_assignment_metadata, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1164a; value=5; format value z8.; run;
proc contents data=t1164a out=t1164b noprint; run;
data t1164o; set t1164b; actual=5+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1164o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1164 rows=' rows;
else do; set t1164o; if not missing(actual) and abs(actual-(23))<=1e-10*max(1,abs(23)) then put 'ROUND3_PASS=T1164';
else put 'ERROR: ROUND3_FAIL=T1164 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1164:; quit;
