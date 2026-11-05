/* K4489 macro_formatted_integer_width, N=10; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4489formatted=%sysfunc(putn(10,z4.));
data k4489o; text=symget('k4489formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4489formatted;

data _null_; if 0 then set k4489o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4489 rows=' rows;
else do; set k4489o; if not missing(actual) and abs(actual-(14))<=1e-9*max(1,abs(14)) then put 'ROUND10_PASS=K4489';
else put 'ERROR: ROUND10_FAIL=K4489 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4489:; quit;
