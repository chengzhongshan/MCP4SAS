/* J3810 sql_into_delimited_values, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3810a; do x=1 to 11; output; end; run;
proc sql noprint; select x into :j3810list separated by '|' from j3810a order by x; quit;
data j3810o; actual=countw(symget('j3810list'),'|'); run;
%symdel j3810list;

data _null_; if 0 then set j3810o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3810 rows=' rows;
else do; set j3810o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND8_PASS=J3810';
else put 'ERROR: ROUND8_FAIL=J3810 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3810:; quit;
