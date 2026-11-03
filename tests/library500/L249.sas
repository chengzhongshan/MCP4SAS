/* L249: left boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/3d scatter plot adding data labels with anno.sas:21 */
data _null_;
length actual $256;
actual=left('   B8');
if actual='B8' and lengthn(actual)=2 then put 'LIB500_PASS=L249';
else put 'ERROR: LIB500_FAIL=L249 actual=' actual;
run;
