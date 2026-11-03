/* L223: lowcase boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-2');
if actual='abc-2' and lengthn(actual)=5 then put 'LIB500_PASS=L223';
else put 'ERROR: LIB500_FAIL=L223 actual=' actual;
run;
