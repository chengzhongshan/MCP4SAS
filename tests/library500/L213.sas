/* L213: upcase boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-2');
if actual='ABC-2' and lengthn(actual)=5 then put 'LIB500_PASS=L213';
else put 'ERROR: LIB500_FAIL=L213 actual=' actual;
run;
