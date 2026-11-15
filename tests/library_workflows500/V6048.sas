/* New workflow V6048; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6048i;
length gene $80 tissue $80;
gene='gene01';tissue='c2';expression=46.2;output;
gene='gene01';tissue='c3';expression=63.27;output;
gene='gene01';tissue='c4';expression=3.34;output;
gene='gene02';tissue='c1';expression=19.26;output;
gene='gene02';tissue='c2';expression=-3.6700000000000004;output;
gene='gene02';tissue='c3';expression=53.4;output;
gene='gene02';tissue='c5';expression=66.54;output;
gene='gene03';tissue='c1';expression=67.39;output;
gene='gene03';tissue='c2';expression=3.46;output;
gene='gene03';tissue='c4';expression=62.6;output;
gene='gene03';tissue='c5';expression=-10.33;output;
gene='gene04';tissue='c1';expression=55.52;output;
gene='gene04';tissue='c3';expression=-24.34;output;
gene='gene04';tissue='c4';expression=21.73;output;
gene='gene04';tissue='c5';expression=33.800000000000004;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6048i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=-999,dsdout=v6048o,outdir4matrix=);
data v6048m(keep=metric value);set v6048o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6048m;set v6048m;format value best32.;run;
proc export data=v6048m outfile="%sysfunc(pathname(work))/V6048.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6048;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6048:;quit;
