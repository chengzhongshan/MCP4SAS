/* L236: strip boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A5  ');
if actual='A5' and lengthn(actual)=2 then put 'LIB500_PASS=L236';
else put 'ERROR: LIB500_FAIL=L236 actual=' actual;
run;
