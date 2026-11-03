/* R839 resolve_macro_expression, N=10; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r839m(); %eval(10*11) %mend;
data r839o; actual=input(RESOLVE('%r839m()'),best32.); run;
%sysmacdelete r839m;

data _null_; if 0 then set r839o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R839 rows=' rows;
else do; set r839o; if not missing(actual) and abs(actual-(110))<=1e-10*max(1,abs(110)) then put 'ROUND2_PASS=R839';
else put 'ERROR: ROUND2_FAIL=R839 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r839:; quit;
