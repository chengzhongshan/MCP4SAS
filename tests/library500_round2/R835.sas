/* R835 resolve_macro_expression, N=6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r835m(); %eval(6*11) %mend;
data r835o; actual=input(RESOLVE('%r835m()'),best32.); run;
%sysmacdelete r835m;

data _null_; if 0 then set r835o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R835 rows=' rows;
else do; set r835o; if not missing(actual) and abs(actual-(66))<=1e-10*max(1,abs(66)) then put 'ROUND2_PASS=R835';
else put 'ERROR: ROUND2_FAIL=R835 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r835:; quit;
