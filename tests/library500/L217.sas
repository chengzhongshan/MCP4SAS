/* L217: upcase boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-6');
if actual='ABC-6' and lengthn(actual)=5 then put 'LIB500_PASS=L217';
else put 'ERROR: LIB500_FAIL=L217 actual=' actual;
run;
