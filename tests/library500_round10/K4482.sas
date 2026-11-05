/* K4482 macro_formatted_integer_width, N=3; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4482formatted=%sysfunc(putn(3,z4.));
data k4482o; text=symget('k4482formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4482formatted;

data _null_; if 0 then set k4482o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4482 rows=' rows;
else do; set k4482o; if not missing(actual) and abs(actual-(7))<=1e-9*max(1,abs(7)) then put 'ROUND10_PASS=K4482';
else put 'ERROR: ROUND10_FAIL=K4482 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4482:; quit;
