/* T1083 dictionary_index_count, N=4; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1083a; array x[4] v1-v4; do j=1 to 4; x[j]=j; end; drop j; run;
%macro t1083m; proc datasets library=work nolist; modify t1083a; %do i=1 %to 4; index create v&i; %end; quit; %mend; %t1083m;
%sysmacdelete t1083m;
proc sql; create table t1083o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1083a'); quit;

data _null_; if 0 then set t1083o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1083 rows=' rows;
else do; set t1083o; if not missing(actual) and abs(actual-(4))<=1e-10*max(1,abs(4)) then put 'ROUND3_PASS=T1083';
else put 'ERROR: ROUND3_FAIL=T1083 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1083:; quit;
