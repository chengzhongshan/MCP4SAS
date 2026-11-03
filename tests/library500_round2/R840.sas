/* R840 resolve_macro_expression, N=11; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r840m(); %eval(11*11) %mend;
data r840o; actual=input(resolve('%r840m()'),best32.); run;
%sysmacdelete r840m;

data _null_; if 0 then set r840o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R840 rows=' rows;
else do; set r840o; if not missing(actual) and abs(actual-(121))<=1e-10*max(1,abs(121)) then put 'ROUND2_PASS=R840';
else put 'ERROR: ROUND2_FAIL=R840 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r840:; quit;
