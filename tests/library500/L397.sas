/* L397: intck boundary 6; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */
data _null_;
actual=intck('month','15JAN2020'd,'20JUL2020'd);
if not missing(actual) and abs(actual-(6)) <= 1e-11*max(1,abs(6)) then put 'LIB500_PASS=L397';
else put 'ERROR: LIB500_FAIL=L397 actual=' actual;
run;
