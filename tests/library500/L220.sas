/* L220: upcase boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:8 */
data _null_;
length actual $256;
actual=upcase('aBc-9');
if actual='ABC-9' and lengthn(actual)=5 then put 'LIB500_PASS=L220';
else put 'ERROR: LIB500_FAIL=L220 actual=' actual;
run;
