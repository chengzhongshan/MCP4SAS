/* L498: trim boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q7   ');
if actual='  q7' and lengthn(actual)=4 then put 'LIB500_PASS=L498';
else put 'ERROR: LIB500_FAIL=L498 actual=' actual;
run;
