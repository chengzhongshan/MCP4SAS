/* L270: substr boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',10,1);
if actual='j' and lengthn(actual)=1 then put 'LIB500_PASS=L270';
else put 'ERROR: LIB500_FAIL=L270 actual=' actual;
run;
