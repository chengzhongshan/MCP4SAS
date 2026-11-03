/* L337: cats boundary 6; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',6,' b ');
if actual='a6b' and lengthn(actual)=3 then put 'LIB500_PASS=L337';
else put 'ERROR: LIB500_FAIL=L337 actual=' actual;
run;
