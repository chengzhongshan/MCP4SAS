/* L394: intck boundary 3; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */
data _null_;
actual=intck('month','15JAN2020'd,'20APR2020'd);
if not missing(actual) and abs(actual-(3)) <= 1e-11*max(1,abs(3)) then put 'LIB500_PASS=L394';
else put 'ERROR: LIB500_FAIL=L394 actual=' actual;
run;
