/* New workflow V6034; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6034i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=52.13;output;
gene='gene01';tissue='c2';expression=35.2;output;
gene='gene01';tissue='c4';expression=50.34;output;
gene='gene01';tissue='c5';expression=18.41;output;
gene='gene01';tissue='c6';expression=58.480000000000004;output;
gene='gene02';tissue='c1';expression=43.26;output;
gene='gene02';tissue='c3';expression=8.4;output;
gene='gene02';tissue='c4';expression=25.470000000000002;output;
gene='gene02';tissue='c5';expression=-16.459999999999997;output;
gene='gene03';tissue='c2';expression=-24.54;output;
gene='gene03';tissue='c3';expression=57.53;output;
gene='gene03';tissue='c4';expression=66.6;output;
gene='gene03';tissue='c6';expression=-15.26;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6034i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6034o,outdir4matrix=);
data v6034m(keep=metric value);set v6034o;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6034m;set v6034m;format value best32.;run;
proc export data=v6034m outfile="%sysfunc(pathname(work))/V6034.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6034;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6034:;quit;
