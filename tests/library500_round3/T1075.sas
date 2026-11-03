/* T1075 attrn_record_length, N=6; source: SAS-Useful-Codes/Macros/GetVarList.sas:102 */

data t1075a; array x[6] v1-v6; do j=1 to 6; x[j]=j; end; drop j; run;
data t1075o; ds=open('t1075a','i'); actual=attrn(ds,'LRECL'); rc=close(ds); run;

data _null_; if 0 then set t1075o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1075 rows=' rows;
else do; set t1075o; if not missing(actual) and abs(actual-(48))<=1e-10*max(1,abs(48)) then put 'ROUND3_PASS=T1075';
else put 'ERROR: ROUND3_FAIL=T1075 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1075:; quit;
