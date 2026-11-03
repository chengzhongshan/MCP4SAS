/* R833 resolve_macro_expression, N=4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r833m(); %eval(4*11) %mend;
data r833o; actual=input(RESOLVE('%r833m()'),best32.); run;
%sysmacdelete r833m;

data _null_; if 0 then set r833o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R833 rows=' rows;
else do; set r833o; if not missing(actual) and abs(actual-(44))<=1e-10*max(1,abs(44)) then put 'ROUND2_PASS=R833';
else put 'ERROR: ROUND2_FAIL=R833 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r833:; quit;
