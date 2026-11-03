/* T1085 dictionary_index_count, N=6; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1085a; array x[6] v1-v6; do j=1 to 6; x[j]=j; end; drop j; run;
%macro t1085m; proc datasets library=work nolist; modify t1085a; %do i=1 %to 6; index create v&i; %end; quit; %mend; %t1085m;
%sysmacdelete t1085m;
proc sql; create table t1085o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1085a'); quit;

data _null_; if 0 then set t1085o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1085 rows=' rows;
else do; set t1085o; if not missing(actual) and abs(actual-(6))<=1e-10*max(1,abs(6)) then put 'ROUND3_PASS=T1085';
else put 'ERROR: ROUND3_FAIL=T1085 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1085:; quit;
