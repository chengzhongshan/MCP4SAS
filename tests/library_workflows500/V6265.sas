/* New workflow V6265; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6265i;
length gene $80;
gene='allele01';ref=34;alt=39;output;
gene='allele02';ref=0;alt=12;output;
gene='allele03';ref=38;alt=10;output;
gene='allele04';ref=12;alt=37;output;
gene='allele05';ref=38;alt=23;output;
gene='allele06';ref=12;alt=25;output;
gene='allele07';ref=10;alt=3;output;
gene='allele08';ref=18;alt=14;output;
run;
%n26_calculate_binomial_P(dsdin=v6265i,dsdout=v6265o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=7);
data v6265m(keep=metric value);set v6265o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6265m;set v6265m;format value best32.;run;
proc export data=v6265m outfile="%sysfunc(pathname(work))/V6265.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6265;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6265:;quit;
