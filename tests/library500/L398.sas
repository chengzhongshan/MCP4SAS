/* L398: intck boundary 7; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */
data _null_;
actual=intck('month','15JAN2020'd,'20AUG2020'd);
if not missing(actual) and abs(actual-(7)) <= 1e-11*max(1,abs(7)) then put 'LIB500_PASS=L398';
else put 'ERROR: LIB500_FAIL=L398 actual=' actual;
run;
