/* L227: lowcase boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-6');
if actual='abc-6' and lengthn(actual)=5 then put 'LIB500_PASS=L227';
else put 'ERROR: LIB500_FAIL=L227 actual=' actual;
run;
