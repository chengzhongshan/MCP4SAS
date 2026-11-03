/* L245: left boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B4');
if actual='B4' and lengthn(actual)=2 then put 'LIB500_PASS=L245';
else put 'ERROR: LIB500_FAIL=L245 actual=' actual;
run;
