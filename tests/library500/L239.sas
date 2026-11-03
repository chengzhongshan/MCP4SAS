/* L239: strip boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A8  ');
if actual='A8' and lengthn(actual)=2 then put 'LIB500_PASS=L239';
else put 'ERROR: LIB500_FAIL=L239 actual=' actual;
run;
