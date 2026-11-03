/* T1090 dictionary_index_count, N=11; source: SAS-Useful-Codes/Macros/base4sas_developer/mp_getdbml.sas:65 */

data t1090a; array x[11] v1-v11; do j=1 to 11; x[j]=j; end; drop j; run;
%macro t1090m; proc datasets library=work nolist; modify t1090a; %do i=1 %to 11; index create v&i; %end; quit; %mend; %t1090m;
%sysmacdelete t1090m;
proc sql; create table t1090o as select count(*) as actual from dictionary.indexes where libname='WORK' and memname=upcase('t1090a'); quit;

data _null_; if 0 then set t1090o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND3_ROWS=T1090 rows=' rows;
else do; set t1090o; if not missing(actual) and abs(actual-(11))<=1e-10*max(1,abs(11)) then put 'ROUND3_PASS=T1090';
else put 'ERROR: ROUND3_FAIL=T1090 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete t1090:; quit;
