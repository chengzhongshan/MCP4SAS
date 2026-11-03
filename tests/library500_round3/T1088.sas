/* T1088 dictionary_index_count, N=9; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1088a; array x[9] v1-v9; do j=1 to 9; x[j]=j; end; drop j; run;
%macro t1088m; proc datasets library=work nolist; modify t1088a; %do i=1 %to 9; index create v&i; %end; quit; %mend; %t1088m;
%sysmacdelete t1088m;
proc sql; create table t1088o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1088a'); quit;

data _null_; if 0 then set t1088o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1088 rows=' rows;
else do; set t1088o; if not missing(actual) and abs(actual-(9))<=1e-10*max(1,abs(9)) then put 'ROUND3_PASS=T1088';
else put 'ERROR: ROUND3_FAIL=T1088 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1088:; quit;
