/* K4485 macro_formatted_integer_width, N=6; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4485formatted=%sysfunc(putn(6,z4.));
data k4485o; text=symget('k4485formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4485formatted;

data _null_; if 0 then set k4485o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4485 rows=' rows;
else do; set k4485o; if not missing(actual) and abs(actual-(10))<=1e-9*max(1,abs(10)) then put 'ROUND10_PASS=K4485';
else put 'ERROR: ROUND10_FAIL=K4485 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4485:; quit;
