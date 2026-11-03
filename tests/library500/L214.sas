/* L214: upcase boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-3');
if actual='ABC-3' and lengthn(actual)=5 then put 'LIB500_PASS=L214';
else put 'ERROR: LIB500_FAIL=L214 actual=' actual;
run;
