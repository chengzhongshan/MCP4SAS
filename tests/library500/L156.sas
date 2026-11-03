/* L156: median boundary 5; source: SAS-Useful-Codes/Macros/Boxplots4GenesInGTExV8ByGrps.sas:549 */
data _null_;
actual=median(25,5,7);
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L156';
else put 'ERROR: LIB500_FAIL=L156 actual=' actual;
run;
