/* L262: substr boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',2,1);
if actual='b' and lengthn(actual)=1 then put 'LIB500_PASS=L262';
else put 'ERROR: LIB500_FAIL=L262 actual=' actual;
run;
