/* L493: trim boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q2   ');
if actual='  q2' and lengthn(actual)=4 then put 'LIB500_PASS=L493';
else put 'ERROR: LIB500_FAIL=L493 actual=' actual;
run;
