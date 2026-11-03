/* L212: upcase boundary 1; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-1');
if actual='ABC-1' and lengthn(actual)=5 then put 'LIB500_PASS=L212';
else put 'ERROR: LIB500_FAIL=L212 actual=' actual;
run;
