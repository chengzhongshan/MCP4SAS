/* L224: lowcase boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-3');
if actual='abc-3' and lengthn(actual)=5 then put 'LIB500_PASS=L224';
else put 'ERROR: LIB500_FAIL=L224 actual=' actual;
run;
