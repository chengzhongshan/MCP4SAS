/* T1174 informat_assignment_metadata, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1174a; value=5; informat value best32.; run;
proc contents data=t1174a out=t1174b noprint; run;
data t1174o; set t1174b; actual=5+informl; run;

data _null_; if 0 then set t1174o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1174 rows=' rows;
else do; set t1174o; if not missing(actual) and abs(actual-(37))<=1e-10*max(1,abs(37)) then put 'ROUND3_PASS=T1174';
else put 'ERROR: ROUND3_FAIL=T1174 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1174:; quit;
