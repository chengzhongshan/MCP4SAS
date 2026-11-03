/* L228: lowcase boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-7');
if actual='abc-7' and lengthn(actual)=5 then put 'LIB500_PASS=L228';
else put 'ERROR: LIB500_FAIL=L228 actual=' actual;
run;
