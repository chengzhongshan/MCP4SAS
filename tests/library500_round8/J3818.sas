/* J3818 sql_into_numbered_variables, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3818a; do x=1 to 9; output; end; run;
proc sql noprint; select x into :j3818item1-:j3818item9 from j3818a order by x; quit;
data j3818o; actual=input(symget('j3818item9'),best32.); run;
%macro j3818clear; %do j=1 %to 9; %symdel j3818item&j; %end; %mend; %j3818clear;
%sysmacdelete j3818clear;

data _null_; if 0 then set j3818o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3818 rows=' rows;
else do; set j3818o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3818';
else put 'ERROR: ROUND8_FAIL=J3818 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3818:; quit;
