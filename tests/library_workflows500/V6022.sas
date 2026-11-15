/* New workflow V6022; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6022i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=0.13;output;
gene='gene01';tissue='c2';expression=-16.8;output;
gene='gene01';tissue='c4';expression=29.34;output;
gene='gene02';tissue='c1';expression=51.26;output;
gene='gene02';tissue='c3';expression=54.4;output;
gene='gene02';tissue='c4';expression=34.47;output;
gene='gene03';tissue='c2';expression=33.46;output;
gene='gene03';tissue='c3';expression=54.53;output;
gene='gene03';tissue='c4';expression=27.6;output;
gene='gene04';tissue='c1';expression=63.52;output;
gene='gene04';tissue='c2';expression=63.59;output;
gene='gene04';tissue='c3';expression=31.66;output;
gene='gene05';tissue='c1';expression=30.65;output;
gene='gene05';tissue='c2';expression=-19.28;output;
gene='gene05';tissue='c4';expression=-12.139999999999999;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6022i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6022o,outdir4matrix=);
data v6022m(keep=metric value);set v6022o;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6022m;set v6022m;format value best32.;run;
proc export data=v6022m outfile="%sysfunc(pathname(work))/V6022.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6022;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6022:;quit;
