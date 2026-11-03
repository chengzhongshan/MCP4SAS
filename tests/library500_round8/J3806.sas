/* J3806 sql_into_delimited_values, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:107 */

data j3806a; do x=1 to 7; output; end; run;
proc sql noprint; select x into :j3806list separated by '|' from j3806a order by x; quit;
data j3806o; actual=countw(symget('j3806list'),'|'); run;
%symdel j3806list;

data _null_; if 0 then set j3806o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND8_ROWS=J3806 rows=' rows;
else do; set j3806o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND8_PASS=J3806';
else put 'ERROR: ROUND8_FAIL=J3806 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete j3806:; quit;
