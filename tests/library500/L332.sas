/* L332: cats boundary 1; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',1,' b ');
if actual='a1b' and lengthn(actual)=3 then put 'LIB500_PASS=L332';
else put 'ERROR: LIB500_FAIL=L332 actual=' actual;
run;
