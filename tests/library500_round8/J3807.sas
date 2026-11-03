/* J3807 sql_into_delimited_values, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3807a; do x=1 to 8; output; end; run;
proc sql noprint; select x into :j3807list separated by '|' from j3807a order by x; quit;
data j3807o; actual=countw(symget('j3807list'),'|'); run;
%symdel j3807list;

data _null_; if 0 then set j3807o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3807 rows=' rows;
else do; set j3807o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND8_PASS=J3807';
else put 'ERROR: ROUND8_FAIL=J3807 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3807:; quit;
