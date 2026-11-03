/* T1437 symexist_after_symdel, N=8; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1437value=8;
data t1437a; actual=&t1437value+%symexist(t1437value); run;
%symdel t1437value;
data t1437o; set t1437a; actual=actual+%symexist(t1437value); run;

data _null_; if 0 then set t1437o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1437 rows=' rows;
else do; set t1437o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1437';
else put 'ERROR: ROUND3_FAIL=T1437 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1437:; quit;
