/* L492: trim boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q1   ');
if actual='  q1' and lengthn(actual)=4 then put 'LIB500_PASS=L492';
else put 'ERROR: LIB500_FAIL=L492 actual=' actual;
run;
