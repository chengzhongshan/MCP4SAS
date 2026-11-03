/* L234: strip boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A3  ');
if actual='A3' and lengthn(actual)=2 then put 'LIB500_PASS=L234';
else put 'ERROR: LIB500_FAIL=L234 actual=' actual;
run;
