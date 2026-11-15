/* New workflow V6263; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6263i;
length gene $80;
gene='allele01';ref=31;alt=1;output;
gene='allele02';ref=20;alt=9;output;
gene='allele03';ref=37;alt=27;output;
gene='allele04';ref=17;alt=27;output;
gene='allele05';ref=30;alt=26;output;
gene='allele06';ref=39;alt=10;output;
run;
%n26_calculate_binomial_P(dsdin=v6263i,dsdout=v6263o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=5);
data v6263m(keep=metric value);set v6263o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6263m;set v6263m;format value best32.;run;
proc export data=v6263m outfile="%sysfunc(pathname(work))/V6263.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6263;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6263:;quit;
