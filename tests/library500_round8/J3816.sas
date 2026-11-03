/* J3816 sql_into_numbered_variables, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3816a; do x=1 to 7; output; end; run;
proc sql noprint; select x into :j3816item1-:j3816item7 from j3816a order by x; quit;
data j3816o; actual=input(symget('j3816item7'),best32.); run;
%macro j3816clear; %do j=1 %to 7; %symdel j3816item&j; %end; %mend; %j3816clear;
%sysmacdelete j3816clear;

data _null_; if 0 then set j3816o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3816 rows=' rows;
else do; set j3816o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3816';
else put 'ERROR: ROUND8_FAIL=J3816 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3816:; quit;
