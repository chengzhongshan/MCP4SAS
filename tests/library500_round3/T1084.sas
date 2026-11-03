/* T1084 dictionary_index_count, N=5; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1084a; array x[5] v1-v5; do j=1 to 5; x[j]=j; end; drop j; run;
%macro t1084m; proc datasets library=work nolist; modify t1084a; %do i=1 %to 5; index create v&i; %end; quit; %mend; %t1084m;
%sysmacdelete t1084m;
proc sql; create table t1084o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1084a'); quit;

data _null_; if 0 then set t1084o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1084 rows=' rows;
else do; set t1084o; if not missing(actual) and abs(actual-(5))<=1e-10*max(1,abs(5)) then put 'ROUND3_PASS=T1084';
else put 'ERROR: ROUND3_FAIL=T1084 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1084:; quit;
