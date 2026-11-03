/* J3814 sql_into_numbered_variables, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3814a; do x=1 to 5; output; end; run;
proc sql noprint; select x into :j3814item1-:j3814item5 from j3814a order by x; quit;
data j3814o; actual=input(symget('j3814item5'),best32.); run;
%macro j3814clear; %do j=1 %to 5; %symdel j3814item&j; %end; %mend; %j3814clear;
%sysmacdelete j3814clear;

data _null_; if 0 then set j3814o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3814 rows=' rows;
else do; set j3814o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3814';
else put 'ERROR: ROUND8_FAIL=J3814 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3814:; quit;
