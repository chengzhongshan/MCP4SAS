/* L233: strip boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A2  ');
if actual='A2' and lengthn(actual)=2 then put 'LIB500_PASS=L233';
else put 'ERROR: LIB500_FAIL=L233 actual=' actual;
run;
