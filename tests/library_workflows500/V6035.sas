/* New workflow V6035; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6035i;
length gene $80 tissue $80;
gene='gene01';tissue='c1';expression=11.13;output;
gene='gene02';tissue='c2';expression=40.33;output;
gene='gene03';tissue='c1';expression=56.39;output;
gene='gene03';tissue='c2';expression=-16.54;output;
gene='gene04';tissue='c1';expression=64.52;output;
gene='gene04';tissue='c2';expression=44.59;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6035i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6035o,outdir4matrix=);
data v6035m(keep=metric value);set v6035o;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6035m;set v6035m;format value best32.;run;
proc export data=v6035m outfile="%sysfunc(pathname(work))/V6035.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6035;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6035:;quit;
