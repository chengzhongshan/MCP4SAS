/* R834 resolve_macro_expression, N=5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r834m(); %eval(5*11) %mend;
data r834o; actual=input(resolve('%r834m()'),best32.); run;
%sysmacdelete r834m;

data _null_; if 0 then set r834o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R834 rows=' rows;
else do; set r834o; if not missing(actual) and abs(actual-(55))<=1e-10*max(1,abs(55)) then put 'ROUND2_PASS=R834';
else put 'ERROR: ROUND2_FAIL=R834 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r834:; quit;
