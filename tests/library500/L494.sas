/* L494: trim boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q3   ');
if actual='  q3' and lengthn(actual)=4 then put 'LIB500_PASS=L494';
else put 'ERROR: LIB500_FAIL=L494 actual=' actual;
run;
