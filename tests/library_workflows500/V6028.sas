/* New workflow V6028; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6028i;
length gene $80 tissue $80;
gene='gene01';tissue='c2';expression=52.2;output;
gene='gene01';tissue='c3';expression=61.27;output;
gene='gene01';tissue='c4';expression=-18.66;output;
gene='gene02';tissue='c1';expression=69.26;output;
gene='gene02';tissue='c2';expression=6.33;output;
gene='gene02';tissue='c3';expression=8.4;output;
gene='gene02';tissue='c5';expression=-29.459999999999997;output;
gene='gene03';tissue='c1';expression=7.39;output;
gene='gene03';tissue='c2';expression=51.46;output;
gene='gene03';tissue='c4';expression=28.6;output;
gene='gene03';tissue='c5';expression=7.67;output;
gene='gene04';tissue='c1';expression=29.52;output;
gene='gene04';tissue='c3';expression=38.660000000000004;output;
gene='gene04';tissue='c4';expression=42.730000000000004;output;
gene='gene04';tissue='c5';expression=20.8;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6028i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6028o,outdir4matrix=);
data v6028m(keep=metric value);set v6028o;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6028m;set v6028m;format value best32.;run;
proc export data=v6028m outfile="%sysfunc(pathname(work))/V6028.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6028;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6028:;quit;
