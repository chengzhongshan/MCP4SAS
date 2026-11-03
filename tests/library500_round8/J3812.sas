/* J3812 sql_into_numbered_variables, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3812a; do x=1 to 3; output; end; run;
proc sql noprint; select x into :j3812item1-:j3812item3 from j3812a order by x; quit;
data j3812o; actual=input(symget('j3812item3'),best32.); run;
%macro j3812clear; %do j=1 %to 3; %symdel j3812item&j; %end; %mend; %j3812clear;
%sysmacdelete j3812clear;

data _null_; if 0 then set j3812o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3812 rows=' rows;
else do; set j3812o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3812';
else put 'ERROR: ROUND8_FAIL=J3812 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3812:; quit;
