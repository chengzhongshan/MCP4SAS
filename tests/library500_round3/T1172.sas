/* T1172 informat_assignment_metadata, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1172a; value=3; informat value best32.; run;
proc contents data=t1172a out=t1172b noprint; run;
data t1172o; set t1172b; actual=3+informl; run;

data _null_; if 0 then set t1172o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1172 rows=' rows;
else do; set t1172o; if not missing(actual) and abs(actual-(35))<=1e-10*max(1,abs(35)) then put 'ROUND3_PASS=T1172';
else put 'ERROR: ROUND3_FAIL=T1172 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1172:; quit;
