/* L339: cats boundary 8; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',8,' b ');
if actual='a8b' and lengthn(actual)=3 then put 'LIB500_PASS=L339';
else put 'ERROR: LIB500_FAIL=L339 actual=' actual;
run;
