/* L265: substr boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',5,1);
if actual='e' and lengthn(actual)=1 then put 'LIB500_PASS=L265';
else put 'ERROR: LIB500_FAIL=L265 actual=' actual;
run;
