/* L491: trim boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q0   ');
if actual='  q0' and lengthn(actual)=4 then put 'LIB500_PASS=L491';
else put 'ERROR: LIB500_FAIL=L491 actual=' actual;
run;
