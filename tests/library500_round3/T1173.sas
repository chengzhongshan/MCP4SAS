/* T1173 informat_assignment_metadata, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1173a; value=4; informat value best32.; run;
proc contents data=t1173a out=t1173b noprint; run;
data t1173o; set t1173b; actual=4+informl; run;

data _null_; if 0 then set t1173o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1173 rows=' rows;
else do; set t1173o; if not missing(actual) and abs(actual-(36))<=1e-10*max(1,abs(36)) then put 'ROUND3_PASS=T1173';
else put 'ERROR: ROUND3_FAIL=T1173 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1173:; quit;
