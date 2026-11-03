/* R838 resolve_macro_expression, N=9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r838m(); %eval(9*11) %mend;
data r838o; actual=input(resolve('%r838m()'),best32.); run;
%sysmacdelete r838m;

data _null_; if 0 then set r838o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R838 rows=' rows;
else do; set r838o; if not missing(actual) and abs(actual-(99))<=1e-10*max(1,abs(99)) then put 'ROUND2_PASS=R838';
else put 'ERROR: ROUND2_FAIL=R838 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r838:; quit;
