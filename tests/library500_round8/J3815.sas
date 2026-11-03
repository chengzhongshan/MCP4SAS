/* J3815 sql_into_numbered_variables, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3815a; do x=1 to 6; output; end; run;
proc sql noprint; select x into :j3815item1-:j3815item6 from j3815a order by x; quit;
data j3815o; actual=input(symget('j3815item6'),best32.); run;
%macro j3815clear; %do j=1 %to 6; %symdel j3815item&j; %end; %mend; %j3815clear;
%sysmacdelete j3815clear;

data _null_; if 0 then set j3815o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3815 rows=' rows;
else do; set j3815o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3815';
else put 'ERROR: ROUND8_FAIL=J3815 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3815:; quit;
