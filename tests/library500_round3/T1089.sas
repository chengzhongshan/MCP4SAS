/* T1089 dictionary_index_count, N=10; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1089a; array x[10] v1-v10; do j=1 to 10; x[j]=j; end; drop j; run;
%macro t1089m; proc datasets library=work nolist; modify t1089a; %do i=1 %to 10; index create v&i; %end; quit; %mend; %t1089m;
%sysmacdelete t1089m;
proc sql; create table t1089o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1089a'); quit;

data _null_; if 0 then set t1089o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1089 rows=' rows;
else do; set t1089o; if not missing(actual) and abs(actual-(10))<=1e-10*max(1,abs(10)) then put 'ROUND3_PASS=T1089';
else put 'ERROR: ROUND3_FAIL=T1089 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1089:; quit;
