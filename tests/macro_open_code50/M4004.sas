/* M4004 wrapped_indexed_loop; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:441 */
%macro m4004m; %local i total; %let total=0; %do i=1 %to 4; %let total=%eval(&total+&i); %end;
data m4004o; actual=&total; run; %mend; %m4004m; %sysmacdelete m4004m;

data _null_; if 0 then set m4004o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND9_ROWS=M4004 rows=' rows;
else do; set m4004o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND9_PASS=M4004';
else put 'ERROR: ROUND9_FAIL=M4004 actual=' actual; end; stop; run;

proc datasets library=work nolist; delete m4004:; quit;
