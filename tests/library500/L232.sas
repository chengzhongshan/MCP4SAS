/* L232: strip boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A1  ');
if actual='A1' and lengthn(actual)=2 then put 'LIB500_PASS=L232';
else put 'ERROR: LIB500_FAIL=L232 actual=' actual;
run;
