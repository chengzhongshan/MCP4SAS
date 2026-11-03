/* J3813 sql_into_numbered_variables, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3813a; do x=1 to 4; output; end; run;
proc sql noprint; select x into :j3813item1-:j3813item4 from j3813a order by x; quit;
data j3813o; actual=input(symget('j3813item4'),best32.); run;
%macro j3813clear; %do j=1 %to 4; %symdel j3813item&j; %end; %mend; %j3813clear;
%sysmacdelete j3813clear;

data _null_; if 0 then set j3813o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3813 rows=' rows;
else do; set j3813o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3813';
else put 'ERROR: ROUND8_FAIL=J3813 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3813:; quit;
