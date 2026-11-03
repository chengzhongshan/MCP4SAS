/* T1180 informat_assignment_metadata, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1180a; value=11; informat value best32.; run;
proc contents data=t1180a out=t1180b noprint; run;
data t1180o; set t1180b; actual=11+informl; run;

data _null_; if 0 then set t1180o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1180 rows=' rows;
else do; set t1180o; if not missing(actual) and abs(actual-(43))<=1e-10*max(1,abs(43)) then put 'ROUND3_PASS=T1180';
else put 'ERROR: ROUND3_FAIL=T1180 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1180:; quit;
