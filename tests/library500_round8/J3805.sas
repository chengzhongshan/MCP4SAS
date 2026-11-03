/* J3805 sql_into_delimited_values, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3805a; do x=1 to 6; output; end; run;
proc sql noprint; select x into :j3805list separated by '|' from j3805a order by x; quit;
data j3805o; actual=countw(symget('j3805list'),'|'); run;
%symdel j3805list;

data _null_; if 0 then set j3805o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3805 rows=' rows;
else do; set j3805o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND8_PASS=J3805';
else put 'ERROR: ROUND8_FAIL=J3805 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3805:; quit;
