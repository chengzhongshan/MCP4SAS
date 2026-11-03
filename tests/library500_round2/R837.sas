/* R837 resolve_macro_expression, N=8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r837m(); %eval(8*11) %mend;
data r837o; actual=input(RESOLVE('%r837m()'),best32.); run;
%sysmacdelete r837m;

data _null_; if 0 then set r837o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R837 rows=' rows;
else do; set r837o; if not missing(actual) and abs(actual-(88))<=1e-10*max(1,abs(88)) then put 'ROUND2_PASS=R837';
else put 'ERROR: ROUND2_FAIL=R837 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r837:; quit;
