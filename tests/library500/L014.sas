/* L014: ceil boundary 3; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/debug_macro_adj_grpnum4close_gene_bed_regs.sas:23 */
data _null_;
actual=ceil(-2.25);
if not missing(actual) and abs(actual-(-2)) <= 1e-11*max(1,abs(-2)) then put 'LIB500_PASS=L014';
else put 'ERROR: LIB500_FAIL=L014 actual=' actual;
run;
