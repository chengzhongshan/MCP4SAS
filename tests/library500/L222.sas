/* L222: lowcase boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-1');
if actual='abc-1' and lengthn(actual)=5 then put 'LIB500_PASS=L222';
else put 'ERROR: LIB500_FAIL=L222 actual=' actual;
run;
