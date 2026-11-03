/* J3820 sql_into_numbered_variables, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3820a; do x=1 to 11; output; end; run;
proc sql noprint; select x into :j3820item1-:j3820item11 from j3820a order by x; quit;
data j3820o; actual=input(symget('j3820item11'),best32.); run;
%macro j3820clear; %do j=1 %to 11; %symdel j3820item&j; %end; %mend; %j3820clear;
%sysmacdelete j3820clear;

data _null_; if 0 then set j3820o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3820 rows=' rows;
else do; set j3820o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3820';
else put 'ERROR: ROUND8_FAIL=J3820 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3820:; quit;
