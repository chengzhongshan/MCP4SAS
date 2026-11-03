/* L396: intck boundary 5; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */
data _null_;
actual=intck('month','15JAN2020'd,'20JUN2020'd);
if not missing(actual) and abs(actual-(5)) <= 1e-11*max(1,abs(5)) then put 'LIB500_PASS=L396';
else put 'ERROR: LIB500_FAIL=L396 actual=' actual;
run;
