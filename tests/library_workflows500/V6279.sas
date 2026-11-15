/* New workflow V6279; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6279i;
length gene $80;
gene='allele01';ref=22;alt=27;output;
gene='allele02';ref=9;alt=2;output;
gene='allele03';ref=4;alt=8;output;
gene='allele04';ref=26;alt=15;output;
gene='allele05';ref=30;alt=9;output;
gene='allele06';ref=34;alt=2;output;
gene='allele07';ref=22;alt=15;output;
gene='allele08';ref=15;alt=28;output;
run;
%n26_calculate_binomial_P(dsdin=v6279i,dsdout=v6279o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=3);
data v6279m(keep=metric value);set v6279o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6279m;set v6279m;format value best32.;run;
proc export data=v6279m outfile="%sysfunc(pathname(work))/V6279.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6279;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6279:;quit;
