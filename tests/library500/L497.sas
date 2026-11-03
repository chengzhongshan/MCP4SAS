/* L497: trim boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q6   ');
if actual='  q6' and lengthn(actual)=4 then put 'LIB500_PASS=L497';
else put 'ERROR: LIB500_FAIL=L497 actual=' actual;
run;
