/* L089: exp boundary 8; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/Get corr P value based on Z, Get Z based on corr R, Get R based on Z.sas:47 */
data _null_;
actual=exp(3);
if not missing(actual) and abs(actual-(20.08553692318767)) <= 1e-11*max(1,abs(20.08553692318767)) then put 'LIB500_PASS=L089';
else put 'ERROR: LIB500_FAIL=L089 actual=' actual;
run;
