/* L013: ceil boundary 2; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/debug_macro_adj_grpnum4close_gene_bed_regs.sas:23 */
data _null_;
actual=ceil(-3.25);
if not missing(actual) and abs(actual-(-3)) <= 1e-11*max(1,abs(-3)) then put 'LIB500_PASS=L013';
else put 'ERROR: LIB500_FAIL=L013 actual=' actual;
run;
