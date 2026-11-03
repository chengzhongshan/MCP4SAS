/* T1433 symexist_after_symdel, N=4; source: SAS-Useful-Codes/Macros/CaculateMulteQTLs_in_GTEx.sas:46 */

%let t1433value=4;
data t1433a; actual=&t1433value+%symexist(t1433value); run;
%symdel t1433value;
data t1433o; set t1433a; actual=actual+%symexist(t1433value); run;

data _null_; if 0 then set t1433o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1433 rows=' rows;
else do; set t1433o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1433';
else put 'ERROR: ROUND3_FAIL=T1433 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1433:; quit;
