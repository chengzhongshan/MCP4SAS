/* L496: trim boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Adding nowd in Proc Report to avoid of useless interactive table.sas:9 */
data _null_;
length actual $256;
actual=trim('  q5   ');
if actual='  q5' and lengthn(actual)=4 then put 'LIB500_PASS=L496';
else put 'ERROR: LIB500_FAIL=L496 actual=' actual;
run;
