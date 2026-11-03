/* J3817 sql_into_numbered_variables, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3817a; do x=1 to 8; output; end; run;
proc sql noprint; select x into :j3817item1-:j3817item8 from j3817a order by x; quit;
data j3817o; actual=input(symget('j3817item8'),best32.); run;
%macro j3817clear; %do j=1 %to 8; %symdel j3817item&j; %end; %mend; %j3817clear;
%sysmacdelete j3817clear;

data _null_; if 0 then set j3817o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3817 rows=' rows;
else do; set j3817o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3817';
else put 'ERROR: ROUND8_FAIL=J3817 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3817:; quit;
