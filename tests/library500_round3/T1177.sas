/* T1177 informat_assignment_metadata, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1177a; value=8; informat value best32.; run;
proc contents data=t1177a out=t1177b noprint; run;
data t1177o; set t1177b; actual=8+informl; run;

data _null_; if 0 then set t1177o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1177 rows=' rows;
else do; set t1177o; if not missing(actual) and abs(actual-(40))<=1e-10*max(1,abs(40)) then put 'ROUND3_PASS=T1177';
else put 'ERROR: ROUND3_FAIL=T1177 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1177:; quit;
