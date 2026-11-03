/* L016: ceil boundary 5; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/debug_macro_adj_grpnum4close_gene_bed_regs.sas:23 */
data _null_;
actual=ceil(-0.25);
if not missing(actual) and abs(actual-(-0)) <= 1e-11*max(1,abs(-0)) then put 'LIB500_PASS=L016';
else put 'ERROR: LIB500_FAIL=L016 actual=' actual;
run;
