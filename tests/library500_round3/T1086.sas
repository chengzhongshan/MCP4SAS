/* T1086 dictionary_index_count, N=7; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1086a; array x[7] v1-v7; do j=1 to 7; x[j]=j; end; drop j; run;
%macro t1086m; proc datasets library=work nolist; modify t1086a; %do i=1 %to 7; index create v&i; %end; quit; %mend; %t1086m;
%sysmacdelete t1086m;
proc sql; create table t1086o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1086a'); quit;

data _null_; if 0 then set t1086o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1086 rows=' rows;
else do; set t1086o; if not missing(actual) and abs(actual-(7))<=1e-10*max(1,abs(7)) then put 'ROUND3_PASS=T1086';
else put 'ERROR: ROUND3_FAIL=T1086 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1086:; quit;
