/* T1178 informat_assignment_metadata, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1178a; value=9; informat value best32.; run;
proc contents data=t1178a out=t1178b noprint; run;
data t1178o; set t1178b; actual=9+informl; run;

data _null_; if 0 then set t1178o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1178 rows=' rows;
else do; set t1178o; if not missing(actual) and abs(actual-(41))<=1e-10*max(1,abs(41)) then put 'ROUND3_PASS=T1178';
else put 'ERROR: ROUND3_FAIL=T1178 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1178:; quit;
