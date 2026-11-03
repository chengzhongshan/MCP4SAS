/* L211: upcase boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-0');
if actual='ABC-0' and lengthn(actual)=5 then put 'LIB500_PASS=L211';
else put 'ERROR: LIB500_FAIL=L211 actual=' actual;
run;
