/* L015: ceil boundary 4; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/debug_macro_adj_grpnum4close_gene_bed_regs.sas:23 */
data _null_;
actual=ceil(-1.25);
if not missing(actual) and abs(actual-(-1)) <= 1e-11*max(1,abs(-1)) then put 'LIB500_PASS=L015';
else put 'ERROR: LIB500_FAIL=L015 actual=' actual;
run;
