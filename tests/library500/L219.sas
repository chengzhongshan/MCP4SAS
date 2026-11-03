/* L219: upcase boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-8');
if actual='ABC-8' and lengthn(actual)=5 then put 'LIB500_PASS=L219';
else put 'ERROR: LIB500_FAIL=L219 actual=' actual;
run;
