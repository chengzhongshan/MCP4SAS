/* T1171 informat_assignment_metadata, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1171a; value=2; informat value best32.; run;
proc contents data=t1171a out=t1171b noprint; run;
data t1171o; set t1171b; actual=2+informl; run;

data _null_; if 0 then set t1171o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1171 rows=' rows;
else do; set t1171o; if not missing(actual) and abs(actual-(34))<=1e-10*max(1,abs(34)) then put 'ROUND3_PASS=T1171';
else put 'ERROR: ROUND3_FAIL=T1171 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1171:; quit;
