/* L221: lowcase boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-0');
if actual='abc-0' and lengthn(actual)=5 then put 'LIB500_PASS=L221';
else put 'ERROR: LIB500_FAIL=L221 actual=' actual;
run;
