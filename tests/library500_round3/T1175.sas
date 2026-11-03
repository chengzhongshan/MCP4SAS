/* T1175 informat_assignment_metadata, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/format varibales in data step with attrib.sas:9 */

data t1175a; value=6; informat value best32.; run;
proc contents data=t1175a out=t1175b noprint; run;
data t1175o; set t1175b; actual=6+informl; run;

data _null_; if 0 then set t1175o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1175 rows=' rows;
else do; set t1175o; if not missing(actual) and abs(actual-(38))<=1e-10*max(1,abs(38)) then put 'ROUND3_PASS=T1175';
else put 'ERROR: ROUND3_FAIL=T1175 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1175:; quit;
