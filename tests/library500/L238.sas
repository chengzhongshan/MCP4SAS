/* L238: strip boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A7  ');
if actual='A7' and lengthn(actual)=2 then put 'LIB500_PASS=L238';
else put 'ERROR: LIB500_FAIL=L238 actual=' actual;
run;
