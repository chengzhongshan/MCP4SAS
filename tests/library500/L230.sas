/* L230: lowcase boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-9');
if actual='abc-9' and lengthn(actual)=5 then put 'LIB500_PASS=L230';
else put 'ERROR: LIB500_FAIL=L230 actual=' actual;
run;
