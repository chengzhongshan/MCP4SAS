/* L225: lowcase boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-4');
if actual='abc-4' and lengthn(actual)=5 then put 'LIB500_PASS=L225';
else put 'ERROR: LIB500_FAIL=L225 actual=' actual;
run;
