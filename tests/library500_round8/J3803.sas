/* J3803 sql_into_delimited_values, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3803a; do x=1 to 4; output; end; run;
proc sql noprint; select x into :j3803list separated by '|' from j3803a order by x; quit;
data j3803o; actual=countw(symget('j3803list'),'|'); run;
%symdel j3803list;

data _null_; if 0 then set j3803o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3803 rows=' rows;
else do; set j3803o; if not missing(actual) and abs(actual-(4))<=1e-9*max(1,abs(4)) then put 'ROUND8_PASS=J3803';
else put 'ERROR: ROUND8_FAIL=J3803 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3803:; quit;
