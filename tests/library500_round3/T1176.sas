/* T1176 informat_assignment_metadata, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1176a; value=7; informat value best32.; run;
proc contents data=t1176a out=t1176b noprint; run;
data t1176o; set t1176b; actual=7+informl; run;

data _null_; if 0 then set t1176o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1176 rows=' rows;
else do; set t1176o; if not missing(actual) and abs(actual-(39))<=1e-10*max(1,abs(39)) then put 'ROUND3_PASS=T1176';
else put 'ERROR: ROUND3_FAIL=T1176 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1176:; quit;
