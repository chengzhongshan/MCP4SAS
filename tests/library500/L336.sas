/* L336: cats boundary 5; source: SAS-Useful-Codes/Macros/GetGenesExons4LatticeGscatter.sas:23 */
data _null_;
length actual $256;
actual=cats(' a ',5,' b ');
if actual='a5b' and lengthn(actual)=3 then put 'LIB500_PASS=L336';
else put 'ERROR: LIB500_FAIL=L336 actual=' actual;
run;
