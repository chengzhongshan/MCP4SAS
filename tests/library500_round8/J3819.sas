/* J3819 sql_into_numbered_variables, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3819a; do x=1 to 10; output; end; run;
proc sql noprint; select x into :j3819item1-:j3819item10 from j3819a order by x; quit;
data j3819o; actual=input(symget('j3819item10'),best32.); run;
%macro j3819clear; %do j=1 %to 10; %symdel j3819item&j; %end; %mend; %j3819clear;
%sysmacdelete j3819clear;

data _null_; if 0 then set j3819o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3819 rows=' rows;
else do; set j3819o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3819';
else put 'ERROR: ROUND8_FAIL=J3819 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3819:; quit;
