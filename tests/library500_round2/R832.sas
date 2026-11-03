/* R832 resolve_macro_expression, N=3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r832m(); %eval(3*11) %mend;
data r832o; actual=input(resolve('%r832m()'),best32.); run;
%sysmacdelete r832m;

data _null_; if 0 then set r832o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R832 rows=' rows;
else do; set r832o; if not missing(actual) and abs(actual-(33))<=1e-10*max(1,abs(33)) then put 'ROUND2_PASS=R832';
else put 'ERROR: ROUND2_FAIL=R832 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r832:; quit;
