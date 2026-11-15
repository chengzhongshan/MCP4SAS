/* New workflow V6031; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6031i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=17.13;output;
gene='gene01';tissue='c3';expression=11.270000000000001;output;
gene='gene02';tissue='c2';expression=8.33;output;
gene='gene02';tissue='c3';expression=45.4;output;
gene='gene03';tissue='c1';expression=-29.61;output;
gene='gene03';tissue='c2';expression=53.46;output;
gene='gene03';tissue='c3';expression=-23.47;output;
gene='gene04';tissue='c1';expression=-8.48;output;
gene='gene04';tissue='c2';expression=-8.41;output;
gene='gene05';tissue='c1';expression=24.65;output;
gene='gene05';tissue='c3';expression=67.79;output;
gene='gene06';tissue='c2';expression=56.85;output;
gene='gene06';tissue='c3';expression=32.92;output;
gene='gene07';tissue='c1';expression=-4.09;output;
gene='gene07';tissue='c2';expression=10.98;output;
gene='gene07';tissue='c3';expression=61.05;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6031i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6031o,outdir4matrix=);
data v6031m(keep=metric value);set v6031o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6031m;set v6031m;format value best32.;run;
proc export data=v6031m outfile="%sysfunc(pathname(work))/V6031.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6031;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6031:;quit;
