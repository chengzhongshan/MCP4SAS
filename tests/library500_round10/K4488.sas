/* K4488 macro_formatted_integer_width, N=9; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4488formatted=%sysfunc(putn(9,z4.));
data k4488o; text=symget('k4488formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4488formatted;

data _null_; if 0 then set k4488o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4488 rows=' rows;
else do; set k4488o; if not missing(actual) and abs(actual-(13))<=1e-9*max(1,abs(13)) then put 'ROUND10_PASS=K4488';
else put 'ERROR: ROUND10_FAIL=K4488 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4488:; quit;
