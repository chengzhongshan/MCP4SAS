/* T1087 dictionary_index_count, N=8; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1087a; array x[8] v1-v8; do j=1 to 8; x[j]=j; end; drop j; run;
%macro t1087m; proc datasets library=work nolist; modify t1087a; %do i=1 %to 8; index create v&i; %end; quit; %mend; %t1087m;
%sysmacdelete t1087m;
proc sql; create table t1087o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1087a'); quit;

data _null_; if 0 then set t1087o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1087 rows=' rows;
else do; set t1087o; if not missing(actual) and abs(actual-(8))<=1e-10*max(1,abs(8)) then put 'ROUND3_PASS=T1087';
else put 'ERROR: ROUND3_FAIL=T1087 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1087:; quit;
