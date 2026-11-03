/* L268: substr boundary 7; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',8,1);
if actual='h' and lengthn(actual)=1 then put 'LIB500_PASS=L268';
else put 'ERROR: LIB500_FAIL=L268 actual=' actual;
run;
