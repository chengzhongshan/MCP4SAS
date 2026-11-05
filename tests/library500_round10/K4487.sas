/* K4487 macro_formatted_integer_width, N=8; source: Carpenter's Complete Guide to the SAS Macro Language, Second Edition.txt:1530 */

%let k4487formatted=%sysfunc(putn(8,z4.));
data k4487o; text=symget('k4487formatted'); actual=lengthn(text)+input(text,best32.); run; %symdel k4487formatted;

data _null_; if 0 then set k4487o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND10_ROWS=K4487 rows=' rows;
else do; set k4487o; if not missing(actual) and abs(actual-(12))<=1e-9*max(1,abs(12)) then put 'ROUND10_PASS=K4487';
else put 'ERROR: ROUND10_FAIL=K4487 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete k4487:; quit;
