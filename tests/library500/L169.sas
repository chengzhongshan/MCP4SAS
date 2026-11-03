/* L169: range boundary 8; source: SAS-Useful-Codes/Macros/SAS-macros-master/stem.sas:94 */
data _null_;
actual=range(.,8,10,-9);
if not missing(actual) and abs(actual-(19)) <= 1e-11*max(1,abs(19)) then put 'LIB500_PASS=L169';
else put 'ERROR: LIB500_FAIL=L169 actual=' actual;
run;
