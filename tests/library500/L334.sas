/* L334: cats boundary 3; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',3,' b ');
if actual='a3b' and lengthn(actual)=3 then put 'LIB500_PASS=L334';
else put 'ERROR: LIB500_FAIL=L334 actual=' actual;
run;
