/* T1167 format_assignment_metadata, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Count need work with Group in Proc SQL.sas:16 */

data t1167a; value=8; format value z8.; run;
proc contents data=t1167a out=t1167b noprint; run;
data t1167o; set t1167b; actual=8+10*(format='Z')+formatl; run;

data _null_; if 0 then set t1167o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1167 rows=' rows;
else do; set t1167o; if not missing(actual) and abs(actual-(26))<=1e-10*max(1,abs(26)) then put 'ROUND3_PASS=T1167';
else put 'ERROR: ROUND3_FAIL=T1167 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1167:; quit;
