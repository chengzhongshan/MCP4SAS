/* New workflow V6271; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6271i;
length gene $80;
gene='allele01';ref=22;alt=16;output;
gene='allele02';ref=20;alt=17;output;
gene='allele03';ref=35;alt=8;output;
gene='allele04';ref=0;alt=32;output;
gene='allele05';ref=31;alt=1;output;
gene='allele06';ref=17;alt=32;output;
gene='allele07';ref=19;alt=27;output;
run;
%n26_calculate_binomial_P(dsdin=v6271i,dsdout=v6271o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=4);
data v6271m(keep=metric value);set v6271o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6271m;set v6271m;format value best32.;run;
proc export data=v6271m outfile="%sysfunc(pathname(work))/V6271.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6271;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6271:;quit;
