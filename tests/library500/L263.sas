/* L263: substr boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',3,1);
if actual='c' and lengthn(actual)=1 then put 'LIB500_PASS=L263';
else put 'ERROR: LIB500_FAIL=L263 actual=' actual;
run;
