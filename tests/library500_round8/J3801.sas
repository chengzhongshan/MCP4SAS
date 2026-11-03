/* J3801 sql_into_delimited_values, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3801a; do x=1 to 2; output; end; run;
proc sql noprint; select x into :j3801list separated by '|' from j3801a order by x; quit;
data j3801o; actual=countw(symget('j3801list'),'|'); run;
%symdel j3801list;

data _null_; if 0 then set j3801o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3801 rows=' rows;
else do; set j3801o; if not missing(actual) and abs(actual-(2))<=1e-9*max(1,abs(2)) then put 'ROUND8_PASS=J3801';
else put 'ERROR: ROUND8_FAIL=J3801 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3801:; quit;
