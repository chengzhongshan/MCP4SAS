/* L331: cats boundary 0; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',0,' b ');
if actual='a0b' and lengthn(actual)=3 then put 'LIB500_PASS=L331';
else put 'ERROR: LIB500_FAIL=L331 actual=' actual;
run;
