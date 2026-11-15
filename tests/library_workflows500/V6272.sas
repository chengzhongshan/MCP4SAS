/* New workflow V6272; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6272i;
length gene $80;
gene='allele01';ref=33;alt=14;output;
gene='allele02';ref=32;alt=32;output;
gene='allele03';ref=22;alt=34;output;
gene='allele04';ref=21;alt=9;output;
gene='allele05';ref=14;alt=14;output;
gene='allele06';ref=8;alt=27;output;
gene='allele07';ref=32;alt=10;output;
gene='allele08';ref=17;alt=1;output;
run;
%n26_calculate_binomial_P(dsdin=v6272i,dsdout=v6272o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=5);
data v6272m(keep=metric value);set v6272o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6272m;set v6272m;format value best32.;run;
proc export data=v6272m outfile="%sysfunc(pathname(work))/V6272.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6272;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6272:;quit;
