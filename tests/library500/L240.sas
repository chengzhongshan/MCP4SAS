/* L240: strip boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A9  ');
if actual='A9' and lengthn(actual)=2 then put 'LIB500_PASS=L240';
else put 'ERROR: LIB500_FAIL=L240 actual=' actual;
run;
