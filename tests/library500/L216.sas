/* L216: upcase boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-5');
if actual='ABC-5' and lengthn(actual)=5 then put 'LIB500_PASS=L216';
else put 'ERROR: LIB500_FAIL=L216 actual=' actual;
run;
