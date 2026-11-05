/* K4486 macro_formatted_integer_width, N=7; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4486formatted=%sysfunc(putn(7,z4.));
data k4486o; text=symget('k4486formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4486formatted;

data _null_; if 0 then set k4486o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4486 rows=' rows;
else do; set k4486o; if not missing(actual) and abs(actual-(11))<=1e-9*max(1,abs(11)) then put 'ROUND10_PASS=K4486';
else put 'ERROR: ROUND10_FAIL=K4486 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4486:; quit;
