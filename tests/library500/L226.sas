/* L226: lowcase boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-5');
if actual='abc-5' and lengthn(actual)=5 then put 'LIB500_PASS=L226';
else put 'ERROR: LIB500_FAIL=L226 actual=' actual;
run;
