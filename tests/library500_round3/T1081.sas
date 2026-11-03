/* T1081 dictionary_index_count, N=2; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1081a; array x[2] v1-v2; do j=1 to 2; x[j]=j; end; drop j; run;
%macro t1081m; proc datasets library=work nolist; modify t1081a; %do i=1 %to 2; index create v&i; %end; quit; %mend; %t1081m;
%sysmacdelete t1081m;
proc sql; create table t1081o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1081a'); quit;

data _null_; if 0 then set t1081o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1081 rows=' rows;
else do; set t1081o; if not missing(actual) and abs(actual-(2))<=1e-10*max(1,abs(2)) then put 'ROUND3_PASS=T1081';
else put 'ERROR: ROUND3_FAIL=T1081 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1081:; quit;
