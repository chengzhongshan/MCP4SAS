/* K4490 macro_formatted_integer_width, N=11; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4490formatted=%sysfunc(putn(11,z4.));
data k4490o; text=symget('k4490formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4490formatted;

data _null_; if 0 then set k4490o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4490 rows=' rows;
else do; set k4490o; if not missing(actual) and abs(actual-(15))<=1e-9*max(1,abs(15)) then put 'ROUND10_PASS=K4490';
else put 'ERROR: ROUND10_FAIL=K4490 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4490:; quit;
