/* L400: intck boundary 9; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */
data _null_;
actual=intck('month','15JAN2020'd,'20OCT2020'd);
if not missing(actual) and abs(actual-(9)) <= 1e-11*max(1,abs(9)) then put 'LIB500_PASS=L400';
else put 'ERROR: LIB500_FAIL=L400 actual=' actual;
run;
