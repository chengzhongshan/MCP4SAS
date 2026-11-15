/* New workflow V6007; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6007i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=45.13;output;
gene='gene01';tissue='c2';expression=-15.799999999999999;output;
gene='gene01';tissue='c3';expression=12.270000000000001;output;
gene='gene01';tissue='c4';expression=-7.66;output;
gene='gene02';tissue='c1';expression=39.26;output;
gene='gene02';tissue='c2';expression=43.33;output;
gene='gene02';tissue='c3';expression=28.400000000000002;output;
gene='gene02';tissue='c4';expression=33.47;output;
gene='gene03';tissue='c1';expression=69.39;output;
gene='gene03';tissue='c2';expression=-20.54;output;
gene='gene03';tissue='c3';expression=-0.47;output;
gene='gene03';tissue='c4';expression=50.6;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6007i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6007o,outdir4matrix=);
data v6007m(keep=metric value);set v6007o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6007m;set v6007m;format value best32.;run;
proc export data=v6007m outfile="%sysfunc(pathname(work))/V6007.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6007;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6007:;quit;
