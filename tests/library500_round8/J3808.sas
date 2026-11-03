/* J3808 sql_into_delimited_values, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3808a; do x=1 to 9; output; end; run;
proc sql noprint; select x into :j3808list separated by '|' from j3808a order by x; quit;
data j3808o; actual=countw(symget('j3808list'),'|'); run;
%symdel j3808list;

data _null_; if 0 then set j3808o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3808 rows=' rows;
else do; set j3808o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND8_PASS=J3808';
else put 'ERROR: ROUND8_FAIL=J3808 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3808:; quit;
