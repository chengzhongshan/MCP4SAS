/* L335: cats boundary 4; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',4,' b ');
if actual='a4b' and lengthn(actual)=3 then put 'LIB500_PASS=L335';
else put 'ERROR: LIB500_FAIL=L335 actual=' actual;
run;
