/* New workflow V6036; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6036i;
length gene $80 tissue $80;
gene='gene01';tissue='c2';expression=-25.8;output;
gene='gene01';tissue='c3';expression=-1.73;output;
gene='gene02';tissue='c1';expression=37.26;output;
gene='gene02';tissue='c2';expression=-13.67;output;
gene='gene02';tissue='c3';expression=3.4;output;
gene='gene03';tissue='c1';expression=-3.61;output;
gene='gene03';tissue='c2';expression=69.46;output;
gene='gene04';tissue='c1';expression=32.52;output;
gene='gene04';tissue='c3';expression=-12.34;output;
gene='gene05';tissue='c2';expression=-27.28;output;
gene='gene05';tissue='c3';expression=68.79;output;
run;
%n26_longdsd2matlabmatrix(dsd=v6036i,var_row=gene,var_col=tissue,data_var=expression,value2asign4missing=0,dsdout=v6036o,outdir4matrix=);
data v6036m(keep=metric value);set v6036o;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6036m;set v6036m;format value best32.;run;
proc export data=v6036m outfile="%sysfunc(pathname(work))/V6036.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6036;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6036:;quit;
