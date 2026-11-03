/* L395: intck boundary 4; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */
data _null_;
actual=intck('month','15JAN2020'd,'20MAY2020'd);
if not missing(actual) and abs(actual-(4)) <= 1e-11*max(1,abs(4)) then put 'LIB500_PASS=L395';
else put 'ERROR: LIB500_FAIL=L395 actual=' actual;
run;
