/* L011: ceil boundary 0; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/debug_macro_adj_grpnum4close_gene_bed_regs.sas:23 */
data _null_;
actual=ceil(-5.25);
if not missing(actual) and abs(actual-(-5)) <= 1e-11*max(1,abs(-5)) then put 'LIB500_PASS=L011';
else put 'ERROR: LIB500_FAIL=L011 actual=' actual;
run;
