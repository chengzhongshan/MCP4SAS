/* K4483 macro_formatted_integer_width, N=4; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4483formatted=%sysfunc(putn(4,z4.));
data k4483o; text=symget('k4483formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4483formatted;

data _null_; if 0 then set k4483o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4483 rows=' rows;
else do; set k4483o; if not missing(actual) and abs(actual-(8))<=1e-9*max(1,abs(8)) then put 'ROUND10_PASS=K4483';
else put 'ERROR: ROUND10_FAIL=K4483 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4483:; quit;
