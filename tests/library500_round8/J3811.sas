/* J3811 sql_into_numbered_variables, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3811a; do x=1 to 2; output; end; run;
proc sql noprint; select x into :j3811item1-:j3811item2 from j3811a order by x; quit;
data j3811o; actual=input(symget('j3811item2'),best32.); run;
%macro j3811clear; %do j=1 %to 2; %symdel j3811item&j; %end; %mend; %j3811clear;
%sysmacdelete j3811clear;

data _null_; if 0 then set j3811o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3811 rows=' rows;
else do; set j3811o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3811';
else put 'ERROR: ROUND8_FAIL=J3811 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3811:; quit;
