/* L231: strip boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:21 */
data _null_;
length actual $256;
actual=strip('  A0  ');
if actual='A0' and lengthn(actual)=2 then put 'LIB500_PASS=L231';
else put 'ERROR: LIB500_FAIL=L231 actual=' actual;
run;
