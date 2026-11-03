/* L160: median boundary 9; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(29,9,11);
if not missing(actual) and abs(actual-(11)) <= 1e-11*max(1,abs(11)) then put 'LIB500_PASS=L160';
else put 'ERROR: LIB500_FAIL=L160 actual=' actual;
run;
