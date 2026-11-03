/* J3809 sql_into_delimited_values, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3809a; do x=1 to 10; output; end; run;
proc sql noprint; select x into :j3809list separated by '|' from j3809a order by x; quit;
data j3809o; actual=countw(symget('j3809list'),'|'); run;
%symdel j3809list;

data _null_; if 0 then set j3809o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3809 rows=' rows;
else do; set j3809o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND8_PASS=J3809';
else put 'ERROR: ROUND8_FAIL=J3809 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3809:; quit;
