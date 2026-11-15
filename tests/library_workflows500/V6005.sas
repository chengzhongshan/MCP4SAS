/* New workflow V6005; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6005i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=4.13;output;
gene='gene01';tissue='c2';expression=-8.799999999999999;output;
gene='gene02';tissue='c1';expression=33.26;output;
gene='gene02';tissue='c2';expression=58.33;output;
gene='gene03';tissue='c1';expression=50.39;output;
gene='gene03';tissue='c2';expression=30.46;output;
gene='gene04';tissue='c1';expression=14.52;output;
gene='gene04';tissue='c2';expression=2.59;output;
gene='gene05';tissue='c1';expression=69.65;output;
gene='gene05';tissue='c2';expression=43.72;output;
gene='gene06';tissue='c1';expression=11.78;output;
gene='gene06';tissue='c2';expression=58.85;output;
gene='gene07';tissue='c1';expression=-1.0899999999999999;output;
gene='gene07';tissue='c2';expression=3.98;output;
gene='gene08';tissue='c1';expression=25.04;output;
gene='gene08';tissue='c2';expression=-22.89;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6005i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6005o,outdir4matrix=);
data v6005m(keep=metric value);set v6005o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6005m;set v6005m;format value best32.;run;
proc export data=v6005m outfile="%sysfunc(pathname(work))/V6005.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6005;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6005:;quit;
