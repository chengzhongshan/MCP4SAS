/* L267: substr boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',7,1);
if actual='g' and lengthn(actual)=1 then put 'LIB500_PASS=L267';
else put 'ERROR: LIB500_FAIL=L267 actual=' actual;
run;
