/* L229: lowcase boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/dosub4running_commands_of_datastep.sas:24 */
data _null_;
length actual $256;
actual=lowcase('AbC-8');
if actual='abc-8' and lengthn(actual)=5 then put 'LIB500_PASS=L229';
else put 'ERROR: LIB500_FAIL=L229 actual=' actual;
run;
