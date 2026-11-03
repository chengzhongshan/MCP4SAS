/* L393: intck boundary 2; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */
data _null_;
actual=intck('month','15JAN2020'd,'20MAR2020'd);
if not missing(actual) and abs(actual-(2)) <= 1e-11*max(1,abs(2)) then put 'LIB500_PASS=L393';
else put 'ERROR: LIB500_FAIL=L393 actual=' actual;
run;
