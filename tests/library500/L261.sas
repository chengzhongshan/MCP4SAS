/* L261: substr boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',1,1);
if actual='a' and lengthn(actual)=1 then put 'LIB500_PASS=L261';
else put 'ERROR: LIB500_FAIL=L261 actual=' actual;
run;
