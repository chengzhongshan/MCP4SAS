/* T1166 format_assignment_metadata, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1166a; value=7; format value z8.; run;
proc contents data=t1166a out=t1166b noprint; run;
data t1166o; set t1166b; actual=7+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1166o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1166 rows=' rows;
else do; set t1166o; if not missing(actual) and abs(actual-(25))<=1e-10*max(1,abs(25)) then put 'ROUND3_PASS=T1166';
else put 'ERROR: ROUND3_FAIL=T1166 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1166:; quit;
