/* R836 resolve_macro_expression, N=7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r836m(); %eval(7*11) %mend;
data r836o; actual=input(resolve('%r836m()'),best32.); run;
%sysmacdelete r836m;

data _null_; if 0 then set r836o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R836 rows=' rows;
else do; set r836o; if not missing(actual) and abs(actual-(77))<=1e-10*max(1,abs(77)) then put 'ROUND2_PASS=R836';
else put 'ERROR: ROUND2_FAIL=R836 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r836:; quit;
