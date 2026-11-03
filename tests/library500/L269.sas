/* L269: substr boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:6 */
data _null_;
length actual $256;
actual=substr('abcdefghij',9,1);
if actual='i' and lengthn(actual)=1 then put 'LIB500_PASS=L269';
else put 'ERROR: LIB500_FAIL=L269 actual=' actual;
run;
