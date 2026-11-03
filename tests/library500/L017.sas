/* L017: ceil boundary 6; source: SAS-Useful-Codes/Easy-For-Error-Codes-SAS/debug_macro_adj_grpnum4close_gene_bed_regs.sas:23 */
data _null_;
actual=ceil(0.75);
if not missing(actual) and abs(actual-(1)) <= 1e-11*max(1,abs(1)) then put 'LIB500_PASS=L017';
else put 'ERROR: LIB500_FAIL=L017 actual=' actual;
run;
