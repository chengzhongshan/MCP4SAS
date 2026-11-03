/* T1082 dictionary_index_count, N=3; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1082a; array x[3] v1-v3; do j=1 to 3; x[j]=j; end; drop j; run;
%macro t1082m; proc datasets library=work nolist; modify t1082a; %do i=1 %to 3; index create v&i; %end; quit; %mend; %t1082m;
%sysmacdelete t1082m;
proc sql; create table t1082o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1082a'); quit;

data _null_; if 0 then set t1082o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1082 rows=' rows;
else do; set t1082o; if not missing(actual) and abs(actual-(3))<=1e-10*max(1,abs(3)) then put 'ROUND3_PASS=T1082';
else put 'ERROR: ROUND3_FAIL=T1082 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1082:; quit;
