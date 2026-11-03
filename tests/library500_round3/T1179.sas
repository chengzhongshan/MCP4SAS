/* T1179 informat_assignment_metadata, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1179a; value=10; informat value best32.; run;
proc contents data=t1179a out=t1179b noprint; run;
data t1179o; set t1179b; actual=10+informl; run;

data _null_; if 0 then set t1179o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1179 rows=' rows;
else do; set t1179o; if not missing(actual) and abs(actual-(42))<=1e-10*max(1,abs(42)) then put 'ROUND3_PASS=T1179';
else put 'ERROR: ROUND3_FAIL=T1179 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1179:; quit;
