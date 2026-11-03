/* L247: left boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B6');
if actual='B6' and lengthn(actual)=2 then put 'LIB500_PASS=L247';
else put 'ERROR: LIB500_FAIL=L247 actual=' actual;
run;
