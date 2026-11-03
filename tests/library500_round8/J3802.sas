/* J3802 sql_into_delimited_values, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3802a; do x=1 to 3; output; end; run;
proc sql noprint; select x into :j3802list separated by '|' from j3802a order by x; quit;
data j3802o; actual=countw(symget('j3802list'),'|'); run;
%symdel j3802list;

data _null_; if 0 then set j3802o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3802 rows=' rows;
else do; set j3802o; if not missing(actual) and abs(actual-(3))<=1e-9*max(1,abs(3)) then put 'ROUND8_PASS=J3802';
else put 'ERROR: ROUND8_FAIL=J3802 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3802:; quit;
