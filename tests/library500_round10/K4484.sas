/* K4484 macro_formatted_integer_width, N=5; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4484formatted=%sysfunc(putn(5,z4.));
data k4484o; text=symget('k4484formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4484formatted;

data _null_; if 0 then set k4484o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4484 rows=' rows;
else do; set k4484o; if not missing(actual) and abs(actual-(9))<=1e-9*max(1,abs(9)) then put 'ROUND10_PASS=K4484';
else put 'ERROR: ROUND10_FAIL=K4484 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4484:; quit;
