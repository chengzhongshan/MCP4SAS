/* R831 resolve_macro_expression, N=2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:123 */

%macro r831m(); %eval(2*11) %mend;
data r831o; actual=input(RESOLVE('%r831m()'),best32.); run;
%sysmacdelete r831m;

data _null_; if 0 then set r831o nobs=rows;
if rows ne 1 then put 'ERROR: ROUND2_ROWS=R831 rows=' rows;
else do; set r831o; if not missing(actual) and abs(actual-(22))<=1e-10*max(1,abs(22)) then put 'ROUND2_PASS=R831';
else put 'ERROR: ROUND2_FAIL=R831 actual=' actual; end; stop; run;
proc datasets library=work nolist; delete r831:; quit;
