/* L215: upcase boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-4');
if actual='ABC-4' and lengthn(actual)=5 then put 'LIB500_PASS=L215';
else put 'ERROR: LIB500_FAIL=L215 actual=' actual;
run;
