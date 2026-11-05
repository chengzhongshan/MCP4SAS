/* K4481 macro_formatted_integer_width, N=2; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4481formatted=%sysfunc(putn(2,z4.));
data k4481o; text=symget('k4481formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4481formatted;

data _null_; if 0 then set k4481o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4481 rows=' rows;
else do; set k4481o; if not missing(actual) and abs(actual-(6))<=1e-9*max(1,abs(6)) then put 'ROUND10_PASS=K4481';
else put 'ERROR: ROUND10_FAIL=K4481 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4481:; quit;
