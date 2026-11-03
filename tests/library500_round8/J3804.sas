/* J3804 sql_into_delimited_values, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3804a; do x=1 to 5; output; end; run;
proc sql noprint; select x into :j3804list separated by '|' from j3804a order by x; quit;
data j3804o; actual=countw(symget('j3804list'),'|'); run;
%symdel j3804list;

data _null_; if 0 then set j3804o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3804 rows=' rows;
else do; set j3804o; if not missing(actual) and abs(actual-(5))<=1e-9*max(1,abs(5)) then put 'ROUND8_PASS=J3804';
else put 'ERROR: ROUND8_FAIL=J3804 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3804:; quit;
