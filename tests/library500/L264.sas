/* L264: substr boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',4,1);
if actual='d' and lengthn(actual)=1 then put 'LIB500_PASS=L264';
else put 'ERROR: LIB500_FAIL=L264 actual=' actual;
run;
