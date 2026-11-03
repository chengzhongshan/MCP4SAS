/* T1072 attrn_record_length, N=3; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1072a; array x[3] v1-v3; do j=1 to 3; x[j]=j; end; drop j; run;
data t1072o; ds=open('t1072a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1072o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1072 rows=' rows;
else do; set t1072o; if not missing(actual) and abs(actual-(24))<=1e-10*max(1,abs(24)) then put 'ROUND3_PASS=T1072';
else put 'ERROR: ROUND3_FAIL=T1072 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1072:; quit;
