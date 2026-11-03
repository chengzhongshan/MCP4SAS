/* L340: cats boundary 9; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',9,' b ');
if actual='a9b' and lengthn(actual)=3 then put 'LIB500_PASS=L340';
else put 'ERROR: LIB500_FAIL=L340 actual=' actual;
run;
