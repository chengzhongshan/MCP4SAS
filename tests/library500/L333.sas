/* L333: cats boundary 2; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',2,' b ');
if actual='a2b' and lengthn(actual)=3 then put 'LIB500_PASS=L333';
else put 'ERROR: LIB500_FAIL=L333 actual=' actual;
run;
