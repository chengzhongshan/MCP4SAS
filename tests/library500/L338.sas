/* L338: cats boundary 7; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',7,' b ');
if actual='a7b' and lengthn(actual)=3 then put 'LIB500_PASS=L338';
else put 'ERROR: LIB500_FAIL=L338 actual=' actual;
run;
