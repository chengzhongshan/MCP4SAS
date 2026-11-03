/* L391: intck boundary 0; source: SAS-Useful-Codes/SAS_Code_Database/SAS 9.1 Proc template for loess_lattice.sas:145 */
data _null_;
actual=intck('month','15JAN2020'd,'20JAN2020'd);
if not missing(actual) and abs(actual-(0)) <= 1e-11*max(1,abs(0)) then put 'LIB500_PASS=L391';
else put 'ERROR: LIB500_FAIL=L391 actual=' actual;
run;
