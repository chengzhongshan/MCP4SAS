/* L235: strip boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A4  ');
if actual='A4' and lengthn(actual)=2 then put 'LIB500_PASS=L235';
else put 'ERROR: LIB500_FAIL=L235 actual=' actual;
run;
