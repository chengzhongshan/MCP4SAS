/* L237: strip boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A6  ');
if actual='A6' and lengthn(actual)=2 then put 'LIB500_PASS=L237';
else put 'ERROR: LIB500_FAIL=L237 actual=' actual;
run;
