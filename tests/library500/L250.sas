/* L250: left boundary 9; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B9');
if actual='B9' and lengthn(actual)=2 then put 'LIB500_PASS=L250';
else put 'ERROR: LIB500_FAIL=L250 actual=' actual;
run;
