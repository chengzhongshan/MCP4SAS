/* Same executable SAS payload for both routes. Frozen book example: companion/research/track_proportions/programs/track_isoforms.sas */
options notes source nodate nonumber fullstimer dlcreatedir;
ods _all_ close;
%let BOOK_OUT=%sysfunc(pathname(work));
%let AF_OUT=&BOOK_OUT;
%let P2_OUT=&BOOK_OUT;
%let P3_OUT=&BOOK_OUT;
%let AF_REMOTE=;
data _null_; rc=dlgcdir(pathname('work'));run;
%put POC_OUT=&BOOK_OUT;

/* BEGIN companion/research/advanced_figures/sources/definitions/ApplyFunc_rowwide.sas */
%macro ApplyFunc_rowwide(
/*The macro is a handy tool to calculate common summary statistics, such as mean, median, sum, n, std, and others that allowed
in proc sql when conducting analysis on groups on ROW-WIDE. Additionally, the macro can generate summary statistics by 
including data from both rows and columns, with special case to generate summary statistics on all columns without providing row_keys or 
on all data in a table from all columns and rows!*/
dsdin,
row_keys,
KeyVar4dsdout,
Regex4col_vars2apply,
SQL_Fun4apply,
dsdout,
KeyVar4dsdout_length=200,
AlsoAppFun4Cols=0
);
%let n=%numargs(&row_keys);
%put macro var row_keys are &row_keys;

%if %eval(&n=0) %then %do;
data &dsdout;
set &dsdin;
&KeyVar4dsdout="AllRows";
run;
%end;
%else %do;
data &dsdout;
length &KeyVar4dsdout $ &KeyVar4dsdout_length;
set &dsdin;
&KeyVar4dsdout=catx(":",
%let i=1;
%do %while (&i<&n);
   %scan(&row_keys,&i,%str( )),
   %let i=%eval(&i+1);
%end;
   %scan(&row_keys,&n,%str( ))
);
run;
%end;


proc contents data=&dsdin out=_vars_ noprint;
run;
proc sql noprint;
select Name into: vars4apply separated by ' '
from _vars_
where prxmatch("/&Regex4col_vars2apply/i",Name);

select count(Name) into: nvars4apply
from _vars_
where prxmatch("/&Regex4col_vars2apply/i",Name);


%if %eval(&AlsoAppFun4Cols=0) %then %do;
proc sql;
create table &dsdout as
select &KeyVar4dsdout,
  %let ii=1;
  %do %while (&ii<&nvars4apply);
   %let Var=%scan(&vars4apply,&ii,%str( ));
   %str(&SQL_Fun4apply(&Var) as New_&Var,)
   %let ii=%eval(&ii+1);
  %end;
   %let Var=%scan(&vars4apply,&ii,%str( ));
   %str(&SQL_Fun4apply(&Var) as New_&Var)
from &dsdout 
group by &KeyVar4dsdout
order by &KeyVar4dsdout;
%end;

%else %if %eval(&AlsoAppFun4Cols=1) %then %do;
proc sql;
create table &dsdout as
select &KeyVar4dsdout,
  %let ii=1;
  %let Var=&SQL_Fun4apply(;
  %do %while (&ii<&nvars4apply);
   %let Var=&Var%scan(&vars4apply,&ii,%str( )),;
   %let ii=%eval(&ii+1);
  %end;
   %let Var=&Var%scan(&vars4apply,&ii,%str( ));
   %str(&Var%) as ALL_Matched_Cols)
from &dsdout 
group by &KeyVar4dsdout
order by &KeyVar4dsdout;

/*Assemble all dup &KeyVar4dsdout for &SQL_Fun4apply*/
proc sql;
create table &dsdout as
select &KeyVar4dsdout,&SQL_Fun4apply(All_Matched_Cols) as &SQL_Fun4apply
from &dsdout
group by &KeyVar4dsdout;

%end;

*Only remove 'New_' within varnames;
%Rename_Del_Rgx4All_Vars(indsd=work.&dsdout,Rgx=New_);

%mend;

/* END companion/research/advanced_figures/sources/definitions/ApplyFunc_rowwide.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/Check_VarnamesInDsd.sas */
%macro Check_VarnamesInDsd(indsd=,Rgx=.,exist_tag=,abort_on_missing=1);

%global &exist_tag;
%let &exist_tag=;
%put Your input sas dsd is &indsd;

*Add quit here to quit process that may prevent the script from running proc contents;
quit;
%put Going to run proc contents to obtain variable list!;
proc contents data=&indsd out=_tmp_(keep=name type) noprint;
run;

%if not %sysfunc(exist(_tmp_)) %then %do;
  %put The proc contents failed to generate variable table!;
  %abort 255;
%end;

data _tmp_1;
set _tmp_;
if prxmatch("/&Rgx/i",name);
run;
proc sql noprint;
select name into: &exist_tag separated by ' '
from _tmp_1;
%put Your rgx (&Rgx) matchs the following vars:;
%put &&&exist_tag;
%put A global macro var &exist_tag is created to have the varnames;

%if %length(&&&exist_tag)=0 %then %do;
  %put No varnames matching with your Rgx (&Rgx);
  %if %sysevalf(&abort_on_missing=1) %then %do;
    %abort 255;
  %end;
%end;
%else %do;
	 proc datasets lib=work nolist;
   delete _tmp_:;
   run;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/Check_VarnamesInDsd.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/FileOrDirExist.sas */
%macro FileOrDirExist(dir) ; 
   %LOCAL rc fileref return; 

   %*arbitrarily assign value 0 to output if dir is empty;
   %*This will avoid of error message issued by fexist later;
   %if %length(&dir)=0 %then %do;
          0
    %end;
	%*It is necessary to add else do macro statement here, otherwise, even if the above is true, later codes will still run by sas;
    %else %do;

   %let rc = %sysfunc(filename(fileref,&dir)) ; 
/*    %if &rc=0 and %sysfunc(fexist(&fileref))  %then %let return=1;     */
/*    %else %let return=0; */
/*    &return */
%*The above failed in SAS OnDemand but works in Windows;
%*The reason is because the sas funciton will return these sas comments if not escaped by %;
%*Note: it is necessary to assign &fileref but not fileref to fexist here!;
   %if %sysevalf(&rc=0 and %symexist(fileref) and %sysfunc(fexist(&fileref)))  %then %do;
       1
   %end;
   %else %do;
       0
   %end;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/FileOrDirExist.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/GetVarAttrib.sas */
%MACRO GetVarAttrib(data, var, fun);
%local data_name dsid rc varnum attrib;

%let data_name = %scan(&data, 1, '(');

%* Initialize &attrib to empty in case there is an error;
%let attrib = ;
%* Open input dataset;
%let dsid = %sysfunc(open(&data_name));
	%** Note that data options are accepted in the open statement but I still use &data_name
	%** because I need it for the %PUT below in case there is an error;
%if &dsid = 0 %then
	%put GETVARATTRIB: ERROR - Dataset %upcase(&data_name) does not exist.;
%else %do;
	%let varnum = %sysfunc(varnum(&dsid,&var));
	%if &varnum = 0 %then
		%put GETVARATTRIB: ERROR - Variable %upcase(&var) does not exist in dataset %upcase(&data_name).;
	%else
		%let attrib = %sysfunc(&fun(&dsid,&varnum));
	%* Close input dataset;
	%let rc = %sysfunc(close(&dsid));
%end;

&attrib
%MEND GetVarAttrib;

/* END companion/research/advanced_figures/sources/definitions/GetVarAttrib.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/GetVarType.sas */
%MACRO GetVarType(data, var);
%local vartype;
%let vartype = %GetVarAttrib(&data, &var, vartype);
&vartype
%MEND GetVarType;

/* END companion/research/advanced_figures/sources/definitions/GetVarType.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/Lattice_gscatter_over_bed_track.sas */
%macro Lattice_gscatter_over_bed_track(
/*
Note: when makedotheatmap=1, in default, the scatterplot will use lattice_subgrp_var to color dots 
across different scatter groups; User can supply an independent variable represented by the macro variable
color_resp_var to color scatter plot dots but different scattergroups will be applied in a union style!
This macro can also draw mixed CNV and scatter plots upper the gene tracks; 
*/
bed_dsd,/*at least contains 7 variables, including chr_var, st_var, end_var, grp_var, and yval_var;
Too many bed regions (>1000) for the gene track will slow down the macro dramatically;
Note: the macro will change the input bed_dsd when supplying xaxis_viewmin and xaxis_viewmax*/
chr_var,/*chromosome name for bed regions*/
st_var,	/*start positions for bed regions*/
end_var,/*end positions for bed regions*/
Variant_Length_Var,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=st-0.5*&Variant_Length_Var and end=st-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!*/
grp_var,/*it is specifically designed for genes used by the lower gene track, such as genesymbols for all its bed regions,
and the upper scatterplot tracks do not use it, thus values for data points in the scatterplots can be missing*/
scatter_grp_var,/*it is used to separate scatterplot data points into different scatter groups, and its values for 
scatterplot data points and gene bed regions in lower gene track should be positve and negative, respectively;
when only draw gene tracks, ensure the the negative value, such as -1, provided for all bed regions, and 
the macro will automatically separate these genes if they are too close to each other!*/
lattice_subgrp_var,/*specifically designed for scatterplots, its values are used to separate dots in scatterplots 
into different groups and color them based on its yval_var value; when only draw gene tracks, just assign the same
value for all bed regions, which can be 0 or any other numeric or character values, as it will be only enable the 
macro to run successful but will not be used for drawing the final figure!*/
yval_var, /*this variable is used to draw y-axis for dots of scatterplots and bed regions of genes*/
yaxis_label=Group,/*The value will be used to label the y-axis*/
linethickness=20, /*line thinkness for gene bed regions*/
track_width=800, /*Final figure width*/
track_height=400,/*Final figure height*/
image_dpi=300,/*Raster output DPI. Lower values reduce SAS ODA Java memory use without changing the layout.*/
dist2st_and_end=0,/*Extend the start and end position for the x-axis*/
dotsize=10,/*Scatter plot marker symbol size, and the default marker is circlefilled dot; when making heatmap, it is
possible to restrict the dotsize as the same for the highlow line size, such as 10pt, which would be different from the 
default value 10 without the pt unit!*/
scattermarker_symbol=circlefilled,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
debug=0,/*keep intermediate data sets for debugging if its value is 1*/
add_grp_anno=1, /*This will add group names, such as gene labels, to each member of grp_var*/
grp_font_size=8, /*font size for gene labels in the lower gene track*/
grp_anno_font_type=italic, /*other type: normal; specifically designed for the gene label font type*/
shift_text_yval=-0.25, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
to liftup or lower text labels on the y axis; the default value is -0.25 to put gene lable under gene tracks;
Change it with the macro var pct4neg_y! Provide very large or small values, such as 9999 or -9999 to remove test labels for genes!*/
amplify_scatterheader_pos=1, /*Provide value 1 to the macro var when the max value for each scatter plot is too large, 
the header position for it should be amplified automatically by the macro*/
yaxis_offset4min=0.05, /*provide 0-1 value or auto to offset the min of the yaxis*/
yaxis_offset4max=0.05, /*provide 0-1 value or auto or to offset the max of the yaxis*/
yoffset4max_drawmarkersontop=0.15,/*Important parameter for controling the height of headroom for labeling top snps on the top;
If draw scatterplot marker labels on the top of track, this fixed value will be used instead of yaxis_offset4max! 
This is very important for customizing the height of top headroom that will be put with the snp labels within it.
the input value for the macro var will be further adjusted internally based on the number of scatter plots and the max value between 
fixed values and adjust value, and finally assigns a value to the parameter offsetmax for y-axis. The macro will print out the following to show the 
value assigned for the offsetmax: offsetmax for y-axis is set as num! please check log for debug!*/
yaxis_auto_ticks=0,/*Provide value 1 to let SAS automatically reduce the number of ticks, which may be useful when non-integer ticks are required for y-axis;
otherwise, only integer ticks will be used to label ticks! However, sometimes this will lead to abnomal yaxis ticks generated!*/
draw_grid4y=0, /*Assign value 1 to draw grid for y axis; default value is 0 for not drawing y grid*/
xaxis_offset4min=0.01, /*provide 0-1 value or auto  to offset the min of the xaxis*/
xaxis_offset4max=0.005, /*provide 0-1 value or auto to offset the max of the xaxis*/
fig_fmt=svg, /*output figure formats: svg, png, jpg, and others*/
refline_thickness=5,/*Use thick refline to separate different tracks*/
refline_color=lightgray,/*Color for reflines*/
pct4neg_y=2, /*the most often used value is 1, and if the value is too large, it will affect the 
 y-axis tick labels by leading to very few y-axis ticks in the final figure!
 So if the above occurs, it is feasible to reduce the value of pct4neg_y or increase
 the value of macro variable track_height inaccordingly.
 compacting the bed track y values by increasing the scatterplot scale, 
 which can reduce the bed trace spaces; It seems that two-fold increasement
 leads to better ticks for different tracks!
 Use value >1 will increase the gene tract, while value < 1 will reduce it!
 Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
 Modify this parameter with the parameter shift_text_yval to adjust gene label!
 Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
 If there are only <4 scatterplots, the value would be usually set as 1 or 2;*/
NotDrawScatterPlot=0,/*This filter will be useful when it is only wanted to draw the bottom bed track
without of the scatterplot; this is the idea solution to draw gene track only!*/ 
offsety=0.05,/*If NotDrowScatterPlot=1, this value will be subtracted from negative gene group value;
This enables the upper and lower part have enough blank space for gene track*/

makedotheatmap=0,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot
Note: if makedotheatmap=1, autolegend will be canceled internally!*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=%nrbquote(&lattice_subgrp_var),/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=darkgreen lightgreen deepskyblue,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=gold mediumred vipk,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=-8,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=8,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/
heatmap_legend_title=%str(Z score),/*Visible title for the heatmap colorbar legend; update this when the scatter colors
are driven by a different effect metric such as beta or odds ratio*/
plot_title=,/*Optional visible title identifying the plotted color metric.*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=,/*Note: this only works when makedotheatmap=0!
Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=cyan blue, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
makeheatmapdotintooneline=0,/*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!*/
dot_yvalue4heatmap_at_oneline=1.5,/*When drawing dot in one line for heatmap, sometimes the arbitrary y value assigned to each dot
may not be optimum, it is advicible to evaluate the initially generated plot and update the value of this macro variable*/
drawdotintooneline_if_totsc_gt=0,/*0 disables automatic flattening and preserves makeheatmapdotintooneline=0. A positive threshold explicitly enables compact tracks.*/
var4label_scatterplot_dots=,/*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the scatterplots;*/
var4mark_ld_scatterplot_dots=,/*Optional character variable containing the selected marker for LD-linked variants and blank otherwise.*/
ld_marker_color=black,/*SAS color name or CXrrggbb value for LD marker text.*/
ld_marker_legend_symbol=*,/*Text shown before LD-linked SNP in the legend.*/
ld_heatmap_var=,/*Optional numeric 0-1 LD r2 variable. Blank keeps LD coloring disabled.*/
ld_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F,/*Separate sequential palette for LD, distinct from the association Z-score palette.*/
ld_heatmap_legend_title=%str(LD r2),/*Title for the opt-in LD inset legend.*/
label_dots_once_on_top=1,/*Put value 1 to label each unique label once on top of scatterplot;
provide 0 for labeling selected dots inside scatterplots;
The script will enlarge the macro var yaxis_offset4max to be 0.1!*/
dist_pct_to_cluster_pos=0.02,/*In terms of labels for top SNPs, use the input pct to calcuate dist based on the distance 
betweent the first label to the last label and define labels into cluster if they are too close to each other if their distance is less than pct_of_total_dist*/
fc2distant_close_labels=3,/*In terms of labels for top SNPs, increase the distance among close labels by input fold change
default value 3 would be good for most situations! Note: this parameter is also used to amplify the space for separating
adjacent SNP labels when adjusting spaces using adj_spaces_among_top_snps=1 with the default setting:
sep4tgt_pos=&fc2distant_close_labels*0.1*(&max_x-&min_x+1)/total_SNPs
Whent the above default distance does not work well, it is suggested to increase or reduce the value of fc2distant_close_labels*/
pct2adj4dencluster=2,/*Input value can be ranging from 0.0001 to 10 or even higher value!
For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 4 top SNPs if track_width between 500 and 800, or 5 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!*/
reflinecolor4selecteddots=gray,/*asign color for the vertical reference lines for userselected dots*/
snp_line_split_ratio=0.99,/*split the vertical reference lines into two parts based on the ratio, with the 
smaller part drawn from the end of point of the larger part to the adjusted position of each snp!*/
text_rotate_angle=90, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=, /*Optional space-delimited SNP=BP labels placed by the local Perl planner.*/
label_headroom_frac=, /*Planned y-axis top offset for the actual label height.*/
label_center_offset=, /*GTL POSITIONOFFSETY in units of the text height.*/
auto_rotate2zero=0, /*supply value 1 when there are <=3 text labels and you want them kept horizontal in the top headroom*/
adj_spaces_among_top_snps=1,/*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/
Yoffset4textlabels=2.5, /*Important parameter to adjust the position of snp label in line with the headroom to the top;
Move up the text labels for target SNPs in specific fold; the default value 2.5 fold works for most cases;
Note: the value of this variable will be automatically changed to enable the target SNP are labeled properly on the top of the figure;
So you may notice that when there is only one SNP for labeling on the top, adjust this value may not efficient, and you may go to 
the line ~1150 of this macro to reduce or increase the ratio of 1000/&track_height to adjust the SNP label manually!*/
font_size4textlabels=10,/*Font size for these text labels*/
move_right_genetxt_pct=0.08,/*When the right most genes are too close to the right boudary, it is necessary to reduce its x-axis position
using the designated pct based on the whole window size that will be automatically calcuated by the macro*/
mk_fake_axis_with_updated_func=1, /*The new func make the xaxis more compacted between gene tracks and scatter plots;*/
sameyaxis4scatter=1,/*Make the same y-axis for scatterplots*/ 
maxyvalue4truncat=30,/*Asign yaxis_value >maxyvalue4trancat as the designated value of maxyvalue4trancat*/ 
adjval4header=-0.5, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/
ordered_sc_grpnames= ,/*Labels for each scatter plot from down to up in order; Use _ to replace blank space within each name and all
_ will be changed into black space by the macro at the end*/
xaxis_label=%nrstr(Position (bp) on chromosome &chr_name), /*The macro var &chr_name will be unquoted after resolved*/        
xaxis_viewmin=,/*arbitrary xaxis min value to show the figure, and it requires to work with thresholdmin=0*/
xaxis_viewmax=,/*arbitrary xaxis max vale to show the figure, and it requires to go along with thresholdmax=0*/
rm_gene_legend=1,/*Remove redundant colorful gene legend*/
scatterdotcols=green orange, /*set colors for the beta directions green orange
(negative and positve values) in scatterplots*/            
dataContrastCols=%str(),
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control;
%str(darkblue darkgreen darkred darkyellow 
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000)*/
/*Note: default is to use %str(), which will apply system colors automatically;
add the following colors separated by blank space if desired,
CXADD8E6 CX98FB98 CXF08080 CX0000FF CXFFF00 CX9F5F9F CXA62A2A CX5F9F9F CX871F78
lightblue lightgreen lightcoral and others for the above!
https://support.sas.com/rnd/base/ods/templateFAQ/Template_colors.html
BLACK #FFFFFF
BLUE #0000FF
YELLOW #FFF000
BLUE VIOLET #9F5F9F
BROWN #A62A2A
CADET BLUE #5F9F9F
DARK BROWN #5C4033
DARK PURPLE #871F78
DUSTY ROSE #856363
GOLD #CD7F32
KHAKI #9F9F5F
NAVY BLUE #23238E
PINK #BC8F8F
SILVER #E6E8FA
TURQUOISE #ADEAEA
RED #FF0000
MAGENTA #FF00FF
BLACK #000000
BRASS #B5A642
BRONZE #8C7853
COPPER #B87333
DARK GREEN #2F4F2F
DARK TAN #97694F
FIREBRICK #8E2323
GREY #C0C0C0
LIME GREEN 32CD32
ORANGE #FF7F00
PLUM #EAADEA
STEEL BLUE #236B8E
VIOLET #4F2F4F
GREEN #00FF00
CYAN #00FFFF
AQUAMARINE #70DB93
BRIGHT GOLD #D9D919
BRONZE II #A67D3D
CORAL #FF7F00
DARK WOOD #855E42
DIM GREY #545454
FOREST GREEN #238E23
INDIAN RED #4E2F2F
MAROON #8E236B
ORCHARD #DB70DB
SCARLET #8C1717
TAN #DB9370
WHEAT #D8D8BF*/

/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
highlow_line_cmd=%str(thickness=8 color=darkorange pattern=solid)

);
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0i3rles1y5mvsn1hrq3i2271rmi.htm;
*SAS marker symbols;

%if %symexist(force_lattice_xaxis_viewmin) and %length(%superq(force_lattice_xaxis_viewmin))>0 %then %do;
%let xaxis_viewmin=%superq(force_lattice_xaxis_viewmin);
%put NOTE: Overriding xaxis_viewmin with force_lattice_xaxis_viewmin=&xaxis_viewmin.;
%end;
%if %symexist(force_lattice_xaxis_viewmax) and %length(%superq(force_lattice_xaxis_viewmax))>0 %then %do;
%let xaxis_viewmax=%superq(force_lattice_xaxis_viewmax);
%put NOTE: Overriding xaxis_viewmax with force_lattice_xaxis_viewmax=&xaxis_viewmax.;
%end;

*If not draw scatter plot on top tracks, reassign the value of yaxis_label as Annotation;
%if &NotDrawScatterPlot=1 %then %let yaxis_label=Annotation;

*Keep a copy of original data set &bed_dsd;
data &bed_dsd._org;
set &bed_dsd;
run;
*Adjust start and end positions based on &Variant_Length_Var if it is not empty;
*This is specifically designed to handle CNVs;
%if %length(&Variant_Length_Var)>0 %then %do;
data &bed_dsd;
set &bed_dsd;
if &Variant_Length_Var>1 then do;
   &end_var=&st_var+0.5*&Variant_Length_Var;
   &st_var=&st_var-0.5*&Variant_Length_Var;
end;
run;
%end;
%else %do;
%let Variant_Length_Var=var_length;
data &bed_dsd;
set &bed_dsd;
Variant_Length_Var=&end_var-&st_var;
run;
%end;
/*%abort 255;*/

%if "&var4label_scatterplot_dots"="&color_resp_var" and "&var4label_scatterplot_dots"^="" %then %do;
*Note: var4label_scatterplot_dots and color_resp_var can not use the same variable;
*To avoid of the crash, let create a temporary variable for color_resp_var;
data &bed_dsd;
set &bed_dsd;
_color_resp_var_=&var4label_scatterplot_dots;
run;
%let color_resp_var=_color_resp_var_;
%end;

%if "&color_resp_var"^="" and  "&dataContrastCols"="" %then %let
dataContrastCols=%str(lightblue lightgreen
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000
);

%Check_VarnamesInDsd(indsd=&bed_dsd,Rgx=&color_resp_var,exist_tag=HasVar);
%if %length(&HasVar)=0 %then %do;
 %put The color_resp_var: &color_resp_var does not exist in the sas dsd &bed_dsd;
 %abort 255;
%end;

%let color_resp_vartype=;
%let Other_num_grpval=;

%if %length(&color_resp_var)>0 %then %do;

/*Also check the color_resp_var type; if it is char var, it is necessary to make numberic
var to link each char var for making format and using them as legend in the final figure*/
%let color_resp_vartype=%GetVarType(&bed_dsd,&color_resp_var);

%if %length(&color_resp_grpdsd)=0 %then %do;    
   proc sql noprint;
   create table _color_resp_dsd_ as
   select unique(&color_resp_var) as &color_resp_var
   from &bed_dsd
   order by &color_resp_var;
   create table _color_resp_dsd_ as
   select &color_resp_var,monotonic() as numgrp4color_resp
   from _color_resp_dsd_;
   %let color_resp_grpdsd=_color_resp_dsd_;
%end;
%else %do;

  *Check the fixed numeric variable numgrp4color_resp in the input dataset &color_resp_grpdsd;
  %Check_VarnamesInDsd(indsd=&color_resp_grpdsd,Rgx=&color_resp_var,exist_tag=HasVar);
  %if %length(&HasVar)=0 %then %do;
   %put The color_resp_var: &color_resp_var does not exist in the sas dsd &bed_dsd;
   %abort 255;
  %end;
  %Check_VarnamesInDsd(indsd=&color_resp_grpdsd,Rgx=numgrp4color_resp,exist_tag=HasVar);
  %if %length(&HasVar)=0 %then %do;
    %put the fixed variable numgrp4color_resp does not exist in the input dataset &color_resp_grpdsd;
    %abort 255;
  %end;

%end;

%if "&color_resp_vartype"="C" %then %do;
    %rank4grps(grps=Others,dsdout=_other_dsd_);
    data _other_dsd_(keep=&color_resp_var numgrp4color_resp);
	set _other_dsd_;
/*	&color_resp_var=grps;*/
	&color_resp_var="";
	numgrp4color_resp=0;
	run;
	*The above dataset will add the "Other" group into the &color_resp_grpdsd if the latter does not have the "Other" group;
    data &color_resp_grpdsd;
	set &color_resp_grpdsd _other_dsd_;
	*This is combine majority missing groups as Others;
	if &color_resp_var="." or &color_resp_var="NaN" or &color_resp_var="" then do;
             &color_resp_var="Other"; numgrp4color_resp=0;
    end;
	run;
/*	%abort 255;*/
	*remove duplicate "Other" group if it is true;
	proc sort data=&color_resp_grpdsd nodupkeys;by &color_resp_var;run;
	*Create numeric and char format for the variable &color_resp_var;
	%mkfmt4grps_by_var(
	grpdsd=&color_resp_grpdsd,
	grp_var=&color_resp_var,
	by_var=numgrp4color_resp,
	outfmt4numgrps=x2y4colresp,
	outfmt4chargrps=y2x4colresp,
	dsd4fmt=dsd4fmt
	);
	*Get the numeric group value for the "Other" group;
	proc sql noprint;
	select start into: Other_num_grpval
	from dsd4fmt
	where Label="Other";
/*	%abort 255;*/

	data &bed_dsd;
	set &bed_dsd;
	*format char &color_resp_var to numeric grps;
	num_&color_resp_var=input(&color_resp_var,x2y4colresp.);
	data &bed_dsd(rename=(num_&color_resp_var=&color_resp_var));
	set &bed_dsd(drop=&color_resp_var);
	run;
%end;

%end;

/*%abort 255;*/

%Check_VarnamesInDsd(indsd=&bed_dsd,Rgx=&var4label_scatterplot_dots,exist_tag=HasVar1);
%if %length(&HasVar1)=0 %then %do;
 %put The color_resp_var: &var4label_scatterplot_dots does not exist in the sas dsd &bed_dsd;
 %abort 255;
%end;

%if %length(&var4mark_ld_scatterplot_dots)>0 %then %do;
 %Check_VarnamesInDsd(indsd=&bed_dsd,Rgx=&var4mark_ld_scatterplot_dots,exist_tag=HasLDMarkerVar);
 %if %length(&HasLDMarkerVar)=0 %then %do;
  %put ERROR: LD marker variable &var4mark_ld_scatterplot_dots does not exist in &bed_dsd.;
  %abort 255;
 %end;
%end;

%if %length(&ld_heatmap_var)>0 %then %do;
 %Check_VarnamesInDsd(indsd=&bed_dsd,Rgx=&ld_heatmap_var,exist_tag=HasLDHeatmapVar);
 %if %length(&HasLDHeatmapVar)=0 %then %do;
  %put ERROR: LD heatmap variable &ld_heatmap_var does not exist in &bed_dsd.;
  %abort 255;
 %end;
%end;

/*%abort 255; */

*Restrict the min and max positions based on the customized viewmin and viewmax;
%put Going to reset the bed positions between xaxis_viewmin and xaxis_viewmax;
data &bed_dsd;
set &bed_dsd;
%if %length(&xaxis_viewmin)>0 %then %do;
if &st_var <= &xaxis_viewmin and &end_var >= &xaxis_viewmin and &yval_var<0 
then &st_var=&xaxis_viewmin;
if &end_var < &xaxis_viewmin 
then delete;
%end;
%if %length(&xaxis_viewmax)>0 %then %do;
if &end_var >= &xaxis_viewmax and &st_var <= &xaxis_viewmax and &yval_var<0 
then &end_var=&xaxis_viewmax;
if &end_var > &xaxis_viewmax 
then delete;
%end;
run;
/*%abort 255;*/
%if %sysevalf(%length(&xaxis_viewmin)>0 or %length(&xaxis_viewmax)>0) %then %do;
  *Also need to adjust the negative y values;
  *for the genes after exclusion of bed regions by customized axis range;
  proc sql noprint;
  select max(&&yval_var) into: min_neg
  from &bed_dsd
  where &yval_var<0;
  data &bed_dsd;
  set &bed_dsd;
  if &yval_var<0 then &yval_var=&yval_var-&min_neg-1;
  run;
%end;

/* %abort 255; */


*Get the total number of distinct elements of scatter_grp_var;
*if n>5, the macro will not draw dashed reference lines for y-axis;
proc sql noprint;
select count(&scatter_grp_var) into: totsc
from (
select distinct &scatter_grp_var
    from &bed_dsd
);
%if &drawdotintooneline_if_totsc_gt>0 and &totsc>&drawdotintooneline_if_totsc_gt %then %let makeheatmapdotintooneline=1;

%if %eval(&NotDrawScatterPlot=1) %then %do;
   %put The macro will only draw the bottom bed track will will keep negative y values only;
   data &bed_dsd;
   set &bed_dsd;
   where &yval_var<0;
   run;
%end;

*Set default colors for negative and positive beta values in the scatterplot;
%if %length(&scatterdotcols)=0 %then %let scatterdotcols=green yellow;

%if &scatter_grp_var eq %then %do;
  %put Please provide the variable for scatter_grp_var, as it is empty!;
  %abort 255;
%end;
*A new numberic group, ord, is created in descending order;
*Note: it is important to sort the group by yval_var ascendingly;
*as the group order will be used to selected genes or non-gene groups for making scatter plot or gene track;

/* %number_rows_by_grp(dsdin=&bed_dsd,grp_var=&grp_var,num_var4sort=&yval_var,descending_or_not=0,dsdout=x1); */

*Use bed region distance to sort the dsd in descending order, and the bed region with the largest distance;
*would be the gene body, which will be subjected to draw with tranparent color;
data &bed_dsd;
set &bed_dsd;
dist=&end_var-&st_var+1;
*truncate large values with the threshold maxyvalue4truncat;
if &yval_var>=&maxyvalue4truncat then &yval_var=&maxyvalue4truncat;

%if &NotDrawScatterPlot=1 %then %do;
 *half the negative values to reduce spaces between different rows of genes in the final track;
 if &yval_var<0 then &yval_var=0.5*&yval_var-&offsety;
%end;

run;

/*%debug_macro;*/
*Also asign all heatmap grp with y-axis value as 0.75;
*keep the original y value as colorvalue;  
data &bed_dsd;
set &bed_dsd;

%if %length(&color_resp_var)=0 %then %do;
/*old_y=&yval_var;*/
*Hack this to use lattice_subgrp_var to color scatter plot dots!;
old_y=&lattice_subgrp_var;
%end;
%else %do;
old_y=&color_resp_var;
%end;

%if &makeheatmapdotintooneline=1 %then %do;
%*Change all positive y values into 0.75;
if &yval_var>=0 then &yval_var=&dot_yvalue4heatmap_at_oneline;
%end;

run;

/*%abort 255;*/

%if &sameyaxis4scatter=1 %then %do;
*Add the maximum y values for each scatter group;
*This will enable the scatter plots have the same y axis;
*Enlarge the maxy4scatter by 1 will separate scatterplots better and have the right yaxis for these scatterplots;
   proc sql noprint;select ceil(max(&yval_var))+1 into: maxy4scatter from &bed_dsd;
   proc sort data=&bed_dsd;by &scatter_grp_var;
   data &bed_dsd;
   set &bed_dsd;
   if last.&scatter_grp_var and &yval_var>0 then do;
    output;
    &st_var=.;&end_var=.;&yval_var=&maxy4scatter;
    output;
   end;
   else do;
    output;
   end;
   by &scatter_grp_var;
%end;

%number_rows_by_grp(dsdin=&bed_dsd,grp_var=&grp_var,num_var4sort=dist,descending_or_not=1,dsdout=x1);

*The final x1 dataset is sorted by grp and yval_var, and a new var ord is created to label;
*each row with number in ascending order by grp;
*The x1 dataset will be splitted into subset dataset by ord;
*The 1st subset dsd will contain all grps with ord=1;
*However, other subset dsds may only contain one of these grps;
*It is important to rescue this by filling the missing grp with values from the 1st subset dsd;

proc sql noprint;
select unique(&chr_var) into: chr_name
from x1;
*remove leading spaces of &chr_name;
%let chr_name=%sysfunc(trim(&chr_name));
%put You chromsome var chr_name has value &chr_name;

*Make fake y axis values by the scatter grp;
*Make sure the &scatter_grp_var have missing values for gene grps;
/*data x1;
set x1;
*Only integer negative values are allowed;
if &yval_var<0 then &yval_var=floor(&pct4neg_y*&yval_var);
run;
*/


*Determine whether there are both positive and negative grp values in the dsd x1;
*If there are no postive grp values, i.e., no grps for scatter plots;
*reasigne mk_fake_axis_with_updated_func=0;
proc sql noprint;
select count(*) into: tot_pos_grps
from x1
where &yval_var>0;

%let crowded_scatter_yaxis_compat=0;
%if &tot_pos_grps=0 %then %do;
 %put There are no positive grp values for the scatter plots;
 %put We will not make fake axis using the updated function;
 %put Instead, default macro make_fake_axis_values4grps will be used to make fake axis values;
 %let mk_fake_axis_with_updated_func=0;
%end;
%else %if &tot_pos_grps>6 %then %do;
 %put NOTE: There are &tot_pos_grps positive scatter groups, so we will keep the richer Neg/Pos fake-axis builder in crowded-axis compatibility mode.;
 %put NOTE: This preserves the older local-GTF behavior that tends to produce more interpretable y-axis labels for many scatter tracks.;
 %let crowded_scatter_yaxis_compat=1;
%end;


*Set scale based on the input value > 1 or < 1;
%if (&pct4neg_y<1) %then %do;
  %let yscale=%sysevalf(1/&pct4neg_y,ceil);
%end;
%else %do;
  %let yscale=%sysevalf(1/%sysevalf(&pct4neg_y,ceil));
%end;


%if %eval(&mk_fake_axis_with_updated_func=1 and &NotDrawScatterPlot=0) %then %do;

%let use_custom_y_ticks=1;
%if %sysevalf(%superq(crowded_scatter_yaxis_compat)=,boolean) %then %let crowded_scatter_yaxis_compat=0;

*This will decide the step value used to draw the final y-axis for the scatter plot;
proc sql noprint;
select max(&yval_var) into: _max_pos_y
from x1;

%let mod_num2keep=2;
%if &amplify_scatterheader_pos=1 %then %let adjval4header=%sysevalf(1*&adjval4header);

*When y max value is small, use all integer ticks;
%if &_max_pos_y<7 %then %do;
		 %let mod_num2keep=1;
		 %if &track_height<400 %then %let mod_num2keep=2;
     %if &amplify_scatterheader_pos=1 %then %let adjval4header=%sysevalf(0.5*&adjval4header);
%end;

*The following contains bugs that would lead to unmatched ticks in the final y-axis;
*If there are too many tick labels genrated from 1 to largest y value, SAS might crash;
*Also when the max value for each scatter plot is too large, the header position for it should be amplified;

%if &_max_pos_y>12 %then %do;
		 %let mod_num2keep=4;
     %if &amplify_scatterheader_pos=1 %then %let adjval4header=%sysevalf(1.5*&adjval4header);
%end;
%if &_max_pos_y>24 %then %do;
		 %let mod_num2keep=6;
     %if &amplify_scatterheader_pos=1 %then %let adjval4header=%sysevalf(2*&adjval4header);
%end;
%put _max_pos_y is &_max_pos_y and the mod_num2keep is set as &mod_num2keep!;

*Note that when the scatter max y value is too large, the step value is increased from 2 to 6;
*When the largest value of y-axis is too large, let set yaxis_auto_ticks=1;

/*A workaround method in case of largest y-axis value >10, which does not address the problem;
   To completely solve the issue, enlarge the height for the final output figure!*/
/*%if &_max_pos_y>20 %then %do;*/
/*  %let mod_num2keep=2;*/
/*  %let yaxis_auto_ticks=1;*/
/*%end;*/

%make_fake_axis4NegPosVal_by_grps(
dsdin=x1,
axis_var=&yval_var, 
/*Both negative and positive values of axis var are allowed to use this macro,
but in each group, only positve (>0) or negative (<0) values are allowed,
and all 0 axis var values will be excluded from the dsdin, 
the above of which are the limitations of the macro!*/
axis_grp=&scatter_grp_var, /*although using the same input, this para is different from make_fake_axis_values4grps*/
new_fake_axis_var=&yval_var._new,
dsdout=x1,
yaxis_macro_labels=ylabelsmacro_var,
fc2scale_pos_vals=&yscale,
/*Use this fc to enlarge the proportion of positive values in the plots
It seems that fc=2 is the best for the final ticks of different tracks;*/
mod_num2keep=&mod_num2keep /*For the final yaxis_macro_labels, default value for the current var  is empty for not filtering these elements by mod; when values, 
such as 2 or 3 are provided, only keep numbers that fulfil the mod(element,num)=0; 
Note that this will only be applied on numbers that are positve!*/
);
%if %length(&ylabelsmacro_var)=0 %then %do;
	 %put WARNING: The y-axis label macro variable is empty after fake-axis generation.;
   %put WARNING: Falling back to automatic y-axis ticks for this panel.;
   %let use_custom_y_ticks=0;
   %let yaxis_auto_ticks=1;
%end;

%if %length(&ylabelsmacro_var)>256 %then %do;
    *Prevent SAS from crash due to the truncated macro var containing single quote;
	 %put WARNING: The y-axis label macro variable is too long, and SAS might crash!;
   %if &crowded_scatter_yaxis_compat=1 %then %do;
   %put NOTE: Crowded-axis compatibility mode will keep the custom y-axis labels despite their length, matching the older local-GTF macro behavior.;
   %end;
   %else %do;
   %put WARNING: Falling back to automatic y-axis ticks for this panel to avoid unsafe macro expansion.;
   %let use_custom_y_ticks=0;
   %let yaxis_auto_ticks=1;
   %end;
%end;

%put Generated y-axis ticks are:;
%if &use_custom_y_ticks=1 %then %do;
%put &ylabelsmacro_var;
%end;
%else %do;
%put [suppressed: ylabelsmacro_var exceeded safe length];
%end;
%end;
%else %do;

%let use_custom_y_ticks=1;

%make_fake_axis_values4grps(
dsdin=x1,
axis_var=&yval_var,
axis_grp=&scatter_grp_var,
new_fake_axis_var=&yval_var._new,
dsdout=x1,
yaxis_macro_labels=ylabelsmacro_var,
fc2scale_pos_vals=&yscale
);

%end;

*The above will expand the y axis positive values by the fc=1/&pct4neg_y;

data x1;
set x1(drop=&yval_var);
rename &yval_var._new=&yval_var;
run;

/***HERE, it was wrong, need to figure out the reason!*/
/*data x1(rename=(&yval_var._new=&yval_var));*/
/*set x1;*/
/**Keep one copy of unchanged yval_var;*/
/*&yval_var._old=&yval_var;*/
/*run;*/
/*%abort 255;*/

*create macro vars for the fake y axis;
*This is just for evaluation, and the macro var fake_y_axis_vals is not used later;
proc sql noprint;
select &yval_var-1 into: fake_y_axis_vals separated by " "
from x1
where &yval_var>0 and grp_end_tag=1;
%put fake y axis values are &fake_y_axis_vals;

*Note: if these added macro vars are empty, it will not affect the data step;
data x1(keep=old_y &Variant_Length_Var &chr_var pos &yval_var &grp_var ord &st_var &end_var &scatter_grp_var &lattice_subgrp_var &var4label_scatterplot_dots &var4mark_ld_scatterplot_dots &ld_heatmap_var);
set x1;
array X{2} &st_var &end_var;
do i=1 to 2;
   pos=X{i};
   *Exclude these CNVs with length >1 in the scatter plot;
   *CNVs will be drawn by highlow plot;
   *if &Variant_Length_Var>1 then pos=.;

   *Failed, as if excluding them, these CNVs can not be labeled on the top of the figure;
   *So just use the middle position of these CNV for labeling purpose;
	if &Variant_Length_Var>1 then pos=0.5*(&st_var+&end_var);
   output;
end;
run;


/*Get max grp number for split data into different dsd*/;
proc sql noprint;
select put(max(ord),best32.),
           put(floor(min(&yval_var)),best32.),
           put(ceil(max(&yval_var)),best32.),
           put(min(&st_var)-&dist2st_and_end,best32.),
           put(max(&end_var)+&dist2st_and_end,best32.) 
       into: max_ord,: min_y,: max_y,: min_x,: max_x
from x1;
%if %eval(&min_x<0) %then %do;
    %let min_x=0;
%end;

*When the makeheatmapdotintooneline=1,the width of the top track would be shorter of 1 unit;
*To rescue this, add the value 1 to the max_y;
%if &makeheatmapdotintooneline=1 or (&label_dots_once_on_top=1 and %length(&var4label_scatterplot_dots)>0) %then %do; 
  %let max_y=%sysevalf(&max_y+1); 
%end;

*Only keep records with yval_var <0 and the max y value;
*Exlude other data will prevent them from drawing in the bed track;
*These excluded data will be plotted with scatterplot;
data x2;
/* set x1(where=(&yval_var<0 or &yval_var=&max_y)); */
set x1(where=(&yval_var<0));
run;

*Get these unique negative values of y;
proc sql noprint;
select unique(abs(&yval_var)) into: yvals4reflines separated by ' '
from x2;

data tmp;
do i=&min_y to &max_y ;
output;
end;
run;
/*proc print;run;*/
proc sql noprint;
select i into: y_axis_values separated by " "
from tmp;
drop table tmp;
/*%abort 255;*/

*Can not replace negative values with empty, as these axis values are for genes;
*The following codes should be deleted;
/*%let y_axis_values=%sysfunc(prxchange(s/-\d+/ /,-1,&y_axis_values));*/
*Also replace -1.0 and other similar negative values;
*This will remove negative and numbers containing ".5" in the final y-axis ticks;

%put Before modification, the contents of ylabelsmacro_var are:;
%if &use_custom_y_ticks=1 %then %do;
%put &ylabelsmacro_var;
%end;
%else %do;
%put [suppressed: ylabelsmacro_var exceeded safe length];
%end;

%if &yaxis_auto_ticks=0 %then %do;
*Remove all negative nums as well as these positive numbers with decimal;
%let ylabelsmacro_var=%sysfunc(prxchange(s/(\-[\d\.]+|\d+\.\d+|\-.*)/ /,-1,&ylabelsmacro_var));
%let ylabelsmacro_var=%sysfunc(prxchange(s/\.d+/ /,-1,&ylabelsmacro_var));
%end;
%else %do;
*This will only remove negative values that are specific to the bottom gene tracks, and the y-axis of scatter plot will kept as it is;
%let ylabelsmacro_var=%sysfunc(prxchange(s/-[\d\.]+/ /,-1,&ylabelsmacro_var));
%end;

%put Final modified yaxis_auto_ticks are:;
%if &use_custom_y_ticks=1 %then %do;
%put &ylabelsmacro_var;
%end;
%else %do;
%put [suppressed: ylabelsmacro_var exceeded safe length];
%end;


/***********************No need this, as it generates missing group that will be put into the legend
in in the final figure*/
/*data x2;*/
/*set x2;*/
/*%do i=1 %to &max_ord;*/
/*if ord=&i then do;*/
/*  &grp_var.&i=&grp_var;*/
/*  pos&i=pos;*/
/*  &yval_var.&i=&yval_var;*/
/*  output;*/
/*end;*/
/*%end;*/
/*run;*/
/************************************************************************************************/

*Get the grp ord of gene grps;
%put NOTE: LATTICE_STAGE gene_group_ord_query_begin;
proc sql noprint;
select unique(ord) into: genegrp_ords separated by " "
from X2;
select count(unique(&grp_var)) into:tot_genegrps
from X2;
%put NOTE: LATTICE_STAGE gene_group_ord_query_complete genegrp_ords=&genegrp_ords tot_genegrps=&tot_genegrps max_ord=&max_ord;

/*
proc print data=x2;
run;
%abort 255;
*/

******************************************Prepare data for making series and scatter plots************************************************************;
/*Need to fill these missing values with pair of non-missing values,
otherwise, the missing values will be a group that will be included 
in the legend in the final figure*/
*Can not simplify the above process by using &tot_genegrps!;
*Do not use the following loop;
/* %do gi=1 %to &tot_genegrps; */
/* %do gi=1 %to &max_ord; */

%do gi=1 %to %ntokens(&genegrp_ords);
%let _gi_=%scan(&genegrp_ords,&gi,%str( ));
%put NOTE: LATTICE_STAGE gene_track_subset_begin gi=&gi ord=&_gi_;
data _y&gi(keep=ord &grp_var&_gi_ pos&_gi_ &yval_var&_gi_);
*Only keep these y values <0 and the max y value for drawing bed track;
*Excluded data will be plotted via scatter plot;
set x2;
*Important to asign enough length for these grps, which are typical for gene names;
length  &grp_var&_gi_ $30.;
if ord=&_gi_ then do;
  &grp_var&_gi_=&grp_var;
  pos&_gi_=pos;
		label pos&_gi_="%unquote(&xaxis_label)";
  &yval_var&_gi_=&yval_var;
		label &yval_var&_gi_="&yaxis_label";
  output;
end;
*No need this, which only add missing values and makes the dataset too big;
/*else do;*/
   *Missing values will be generated for ord not equal to &_gi_;
  /*grp_var may be numeric or char, 
   just use its original value here,
   will remove it later*/
/*  &grp_var&_gi_=&grp_var;*/
/*  pos&_gi_=.;*/
/*		label pos&_gi_="Position (bp) on chromosome &chr_name";*/
/*  &yval_var&_gi_=.;*/
/*		label &yval_var&_gi_="&yaxis_label";*/
/*  output;*/
/*end;*/
run;
%put NOTE: LATTICE_STAGE gene_track_subset_built gi=&gi ord=&_gi_ ds=_y&gi;


/*proc sort data=_y&_gi_;by &grp_var&_gi_ ord pos&_gi_;*/
/*run;*/

/*get the 1st two records without missing values,
which will be used for fill these missing values later*/
%if %sas_dsd_exist(_y&gi)=0 %then %do;
     %put WARNING: The temporary gene-track dataset _y&gi does not exist, so this subgroup will be skipped.;
%end;
%else %do;
data _y&_gi_._ _y&_gi_._missing;
/*set _y&_gi_;*/
set _y&gi;
if pos&_gi_^=. then output _y&_gi_._;
else output _y&_gi_._missing;
/*create the common var n with values of 1 or 2
for matching with non-missing values from y1_*/
run;
/*%if &_gi_=4 %then %abort 255;*/

*Directly count whether the temporary subgroup keeps any non-missing positions;
*instead of relying on helper macros that may abort on empty inputs.;
%let _ygi_nonmissing=0;
proc sql noprint;
select count(*) into: _ygi_nonmissing trimmed
from _y&_gi_._
where pos&_gi_^=.
;
quit;
%if %sysevalf(%superq(_ygi_nonmissing)=,boolean) %then %let _ygi_nonmissing=0;
%put NOTE: LATTICE_STAGE gene_track_subset_nonmissing_count gi=&gi ord=&_gi_ count=&_ygi_nonmissing;
%let tot_missing=1;
%if %sysevalf(&_ygi_nonmissing>0) %then %do;
%let tot_missing=0;
%end;
%else %do;
%put WARNING: The temporary gene-track dataset _y&_gi_._ has no non-missing positions, so it will be skipped.;
proc datasets lib=work nolist;
delete _y&_gi_._;
quit;
%end;
/*%put &tot_missing;*/
/* %if %sysfunc(exist(work._y&_gi_._)) %then %do; */
%if "&tot_missing" eq "0" and %sysfunc(exist(work._y&_gi_._)) %then %do;
data _y&_gi_._missing;
set _y&_gi_._missing;
if mod(_n_,2)=0 then n=2;
else n=1;
/*Also get the 1st two non-missing values and 
label them with 1 and 2 for matching*/
data _y&_gi_._1;
set _y&_gi_._;
n=_n_;
if _n_<=2;
run;
proc sql;
create table _y&_gi_._filled as
select a.n as n&_gi_, b.*
from _y&_gi_._missing as a,
     _y&_gi_._1 as b
where a.n=b.n;
/*merge y1_filled with y1_*/
data _y&_gi_._final(drop=ord n);
set _y&_gi_._filled(drop=n&_gi_) _y&_gi_._;
run;
%put NOTE: LATTICE_STAGE gene_track_subset_finalized gi=&gi ord=&_gi_;

*better to add the &grp_var1 into other subset dsd, as these subset dsd may missing some genes;
%if 	%eval(&gi>1) %then %do;
proc sql;
create table y1fory&gi as
 select * from _y1_final
  where &grp_var.1 NOT in (select &grp_var.&_gi_ from _y&_gi_._final);

*Manually make all pos1 as _n_ (out of the xaix range);
*leading to no drawing of the y1 region but inclusion of y1 legend in the final series plot;
data y1fory&gi;
set y1fory&gi;
pos1=_n_;
run;
  
proc sql;
create table _y&_gi_._final_ as 
select * from _y&_gi_._final 
union all
select * from y1fory&gi;

*Rename _y&gi._final_ back as _y&gi._final_;
*This is because the _y&gi._final is used by union and can not be replace within the same proc sql;
data _y&_gi_._final;
set _y&_gi_._final_;
*Make values < &min_x as .;
if pos&_gi_ < &min_x then pos&_gi_=.;
run;
%end;

/*The sorting of dataset by gene is important for the coloring in the seriesplot*/
proc sort data=_y&_gi_._final;
by grp&_gi_;
run;
%put NOTE: LATTICE_STAGE gene_track_subset_sorted gi=&gi ord=&_gi_;
%end;
%end;
%end;

%put NOTE: LATTICE_STAGE gene_track_final_merge_begin;
data final;
set
%do ti=1 %to %sysfunc(countw(&genegrp_ords));
%let i=%scan(&genegrp_ords,&ti);
 %if %sysfunc(exist(work._y&i._final)) %then %do;
    _y&i._final
 %end;
%end;
;
%put NOTE: LATTICE_STAGE final_gene_track_merge_complete;

/*
*change the Y6 as other group for debugging;
proc print data=WORK._Y6_FINAL;
run;
%abort 255;
*/

/*
proc print data=final(obs=50);run;
%abort 255;
*/

*Need to keep var4label_scatterplot_dots when  makeheatmapdotintooneline=1;

data final;
*Keep &st_var &end_var for CNV highlowplot if necessary;
merge final x1(where=(&yval_var>=0) keep=old_y &Variant_Length_Var &st_var &end_var pos &yval_var &grp_var &scatter_grp_var &lattice_subgrp_var &var4label_scatterplot_dots &var4mark_ld_scatterplot_dots &ld_heatmap_var);
*Add back these excluded data;
run;
%if %length(&ld_heatmap_var)>0 %then %do;
data final;
set final;
_LD_PLOT_Y_=.;
if not missing(&ld_heatmap_var) then _LD_PLOT_Y_=&yval_var;
run;
%end;
%put NOTE: LATTICE_STAGE positive_signal_merge_complete;
*Asign a specific values for gene with missing value;
proc sql noprint;
select grp1 into: genenames separated by " "
from 
(select unique(grp1)
from final
where grp1^="" and &yval_var.1<0);
%let onegenename=%scan(&genenames,1,%str( ));
%put selected genename for missing value is &onegenename;

*Asign a specific values for non-gene grp with missing value;
proc sql noprint;
select &grp_var into: grpnames separated by " "
from 
(select unique(&grp_var)
from x1
where &yval_var>=0);
%let onegrpname=%scan(&grpnames,1,%str( ));
%put selected grpname for missing value of non-gene group is &onegrpname;
/* %abort 255; */
data final;
set final;
array C{*} _character_;
*The above array may include the var &var4label_scatterplot_dots for labeling users selected dots in scatterplot;
*We need to exclude the var &var4label_scatterplot_dots;
*Need to pay attention to other variables that were character but not included in the gene group variables!;
do ci=1 to dim(C);
   grpname=vname(C{ci});
/*    if grpname^="&var4label_scatterplot_dots" then do; */
/*    The following is better; */
      if prxmatch('/^grp\d+$/',grpname) then do;
			*The &grp_var.1 to &grp_var.&tot_genegrps are for genes, thus they are only needed to be replaced for missing values with genename!;
		       if ci<=&tot_genegrps then do;
                 if C{ci}="" then C{ci}="&onegenename";
				end;
				*For non-gene grps, use non-gene grp name to fill missing grp value;
				*This is not right, need to use gene name to fill all missing subgrps;
				*Because all sub grps &grp_var&i only contain gene or exon bed regions;
				else do;
/* 					if C{ci}="" then C{ci}="&onegrpname"; */
					if C{ci}="" then C{ci}="&onegenename";
				end;
	 end;
end;
/*array N{*} _numeric_;*/
/*Can not asign values to numeric variable with missing values;*/
/* do ni=1 to dim(N); */
/*    if N{ni}=. then N{ni}=.; */
/* end; */
drop ci;
run;
/* %abort 255; */
*prevent missing data draw in the final scatterplot legend;
*Here would be a potential bug if the var lattice_subgrp_var is character;
*Address it by checking var type;
%check_var_type(
dsdin=final,
var_rgx=&lattice_subgrp_var
);
%put lattice_subgrp_var &lattice_subgrp_var variable type is &var_type;
%put NOTE: LATTICE_STAGE lattice_subgrp_type_checked;

%if %length(&lattice_subgrp_var)=0 %then %do;
  %put WARNING: The lattice_subgrp_var is empty. Falling back to scatter_grp_var=&scatter_grp_var.;
  %let lattice_subgrp_var=&scatter_grp_var;
  %check_var_type(
  dsdin=final,
  var_rgx=&lattice_subgrp_var
  );
  %put lattice_subgrp_var fallback variable type is &var_type;
%end;

*For numeric lattice_subgrp_var;
%if %eval(&var_type=1) %then %do;
data _null_;
set final(keep=&lattice_subgrp_var where=(&lattice_subgrp_var^=.));
if _n_=1 then do;
  call symputx('lattice_grp1',&lattice_subgrp_var);
end;
else do;
		stop;
end;
run;

*To rescue the above when not drawing scatterplot, the macro var lattice_grp1 would be missing;
%if (&NotDrawScatterPlot=1) %then %let lattice_grp1=0;

data final;
set final;
if &lattice_subgrp_var=. then &lattice_subgrp_var=&lattice_grp1;
run;
%end;
%else %do;
*For character lattice_subgrp_var;
data _null_;
set final(keep=&lattice_subgrp_var where=(&lattice_subgrp_var^=""));
if _n_=1 then do;
  call symputx('lattice_grp1',&lattice_subgrp_var);
end;
else do;
		stop;
end;
run;
data final;
set final;
if &lattice_subgrp_var="" then &lattice_subgrp_var=&lattice_grp1;
run;

%end;
/*%abort 255;*/

/*
proc print data=final(obs=50);run;
%abort 255;
*/

%if &add_grp_anno=1 %then %do;

***********************************Add grp label for making text identification*******************************;
/*proc print data=final;run;*/

data final(drop=A);
*Ensure the lower gene track name have enough length;
length grp_label $50.;
set final;
*Also need to add grp labels for the first grp, which usually represent genes for all grps;
*It is important to get the lag value of &grp_var.1 here;
*if use the lag function within the if else condition,;
*du to the _n_=1 was passed without of determine the 1st lag value,;
*the output is not as expected.;
A=lag(&grp_var.1);
if _n_=1 then do;
  grp_label=&grp_var.1;
end;
else do;
  if trim(&grp_var.1)^=trim(A) then grp_label=&grp_var.1;
  if pos1=. then grp_label=""; 
end;
*Adjust the y value to make the label about the left a little bit in the gene track;
*shift_text_yval can be negative or positve value;
if &yval_var.1^=. then _y_=&yval_var.1 + (&shift_text_yval*&pct4neg_y);

*adjust pos1 value if the xaxi_viewmin is set up;
%if %length(&xaxis_viewmin)>0 %then %do;
  if pos1<&xaxis_viewmin then pos1=&xaxis_viewmin;
%end;
run;

/*
proc print data=final(obs=50);run;
%abort 255;
*/

%end;


%if %length(&ordered_sc_grpnames)>0 and &NotDrawScatterPlot=0 %then %do;
    *Add a dataset containing scatterplot headers;
    *Note: scatter_grp_var should be in numeric;
    *Also adjust the x-axis position for the group headers;
    proc sql;
    create table header_dsd as
    select distinct 
    &scatter_grp_var as sc_grp, 
    &yval_var+(&adjval4header) as header_yval,avgpos
    from (select *, 
          0.5*(&max_x+&min_x) as avgpos 
          from x1)
    where &scatter_grp_var >0
    group by &scatter_grp_var
    having &yval_var=max(&yval_var);
    *Now get the scatter plot group names;
    %rank4grps(
    grps=&ordered_sc_grpnames,
    dsdout=scgrpnames
    );
    *Note: here all _ included in the name of scatter plot are changed into blank space;
    proc sql;
    create table header_dsd as
    select a.*,prxchange('s/_/ /',-1,b.grps) as header_grp
    from header_dsd as a,
         scgrpnames as b
    where a.sc_grp=b.num_grps;
    quit;

    *Add the header dsd into the final dsd;
    *No need to adjust the avgpos by header length for each header grp;
    *SAS will adjust it automatically with the markercharacterposition=top in proc template;
    *But the code may be useful in adjusting gene labels;
/*     data header_dsd; */
/*     set header_dsd; */
/*     avgpos=avgpos*(1-0.005*(countc(header_grp))); */
/*     run; */
    data final;
    merge final header_dsd;
    run;
    *Get the minimum value of header_yval and the avgpos to fill these missing value after merge with final dsd;
    proc sql noprint;
    select header_yval, avgpos, header_grp 
     into: hd_min,:mid_pos,:hgrp
    from header_dsd
    group by sc_grp
    having sc_grp=min(sc_grp);
    quit;
    data final;
    set final;
    if sc_grp=. then do;
     avgpos=&mid_pos;
     header_yval=&hd_min;
     header_grp="";
    end;
    run;
    /* proc print;run; */
%end;

*Get min and max postive old y value for heatmap;
proc sql noprint;
select floor(min(old_y)),ceil(max(old_y)) into: min_old_y,: max_old_y
from final;
quit;
*To exclude negative old_y in the range of min and max, use the following code;
/*(where=(old_y>=0));*/

*Adjust avgpos for scatter track labels if the xaxis_viewmin and xaxis_viewmax are provided with values;
%let _avg_pos=%sysevalf(0.5*(&max_x+&min_x));
%if (%length(&xaxis_viewmin)>0 and %length(&xaxis_viewmax)>0) %then %do;
  %let _avg_pos=%sysevalf(0.5*(&xaxis_viewmin+&xaxis_viewmax));
  %let xaxis_offset4min=%sysfunc(min(&xaxis_offset4min,0.01));
  %let xaxis_offset4max=%sysfunc(min(&xaxis_offset4max,0.005));
%end;
%if (%length(&xaxis_viewmin)=0 and %length(&xaxis_viewmax)>0) %then %do;
  %let _avg_pos=%sysevalf(0.5*(&min_x+&xaxis_viewmax));
  %let xaxis_offset4min=%sysfunc(min(&xaxis_offset4min,0.01));
  %let xaxis_offset4max=%sysfunc(min(&xaxis_offset4max,0.005));
%end;
%if (%length(&xaxis_viewmin)>0 and %length(&xaxis_viewmax)=0) %then %do;
  %let _avg_pos=%sysevalf(0.5*(&xaxis_viewmin+&max_x));
  %let xaxis_offset4min=%sysfunc(min(&xaxis_offset4min,0.01));
  %let xaxis_offset4max=%sysfunc(min(&xaxis_offset4max,0.005));
%end;
data final;
set final;
avg_pos=&_avg_pos + 0;
*Preallocate label plotting columns during an existing rewrite so the later
 hash update can modify only matching target rows in place.;
newpos=pos;
top_y4label=&max_y;

run;

*De-duplicate repeated labels without dropping a singleton label by row parity.;
*Key only by label text: x1 expands each variant to start/end plotting positions,;
*so a label+position key incorrectly retains the same rsID twice.;
%if %length(&var4label_scatterplot_dots)>0 %then %do;
data final;
  if _n_=1 then do;
    declare hash _seen_target_labels();
    _seen_target_labels.defineKey("&var4label_scatterplot_dots");
    _seen_target_labels.defineData("&var4label_scatterplot_dots");
    _seen_target_labels.defineDone();
  end;
  modify final;
  if &var4label_scatterplot_dots^="" and pos^=. then do;
    if _seen_target_labels.check()=0 then &var4label_scatterplot_dots="";
    else _seen_target_labels.add();
  end;
  replace;
run;
%end;


*Transform data to label selected dots only once if multiple satterplots containing the same label;
%if (%length(&var4label_scatterplot_dots)>0 and &label_dots_once_on_top=1 and &NotDrawScatterPlot=0) %then %do;
    %put NOTE: LATTICE_STAGE top_label_transform_begin;
    data _xtag_;
    set final;
    xtag=_n_;
    _tmp_=_n_;
    where &var4label_scatterplot_dots^="" and pos^=.;
    keep &var4label_scatterplot_dots xtag _tmp_ pos;
    run;

    *Collapse repeated label rows before any spacing adjustment so a SNP that;
    *appears in multiple tracks is treated as one top label with one position.;
    proc sort data=_xtag_;
    by &var4label_scatterplot_dots pos _tmp_;
    run;

    data _xtag_;
    set _xtag_;
    by &var4label_scatterplot_dots;
    if first.&var4label_scatterplot_dots;
    run;
    proc sql noprint;
	select count(*) into: total_target_labels
	from (
	select distinct &var4label_scatterplot_dots 
    from _xtag_
    ); 
  %let effective_font_size4textlabels=&font_size4textlabels;
  %let effective_yoffset4textlabels=&Yoffset4textlabels;

  *When there is less then 4 SNPs for labeling at the top of the local Manhattan plot, reset the following rotation angle macro var to 0;
  *and increase 4 fold for the the dist_pct_to_cluster_pos;
  *First decide the cutoff of total_target_labels based on the width of figure;
 %if &track_width <= 500 %then %do;
     %let label_n_cutoff=3;
%end;
%else %if (&track_width>500 and  &track_width<800) %then %do;
     %let label_n_cutoff=4;
%end;
%else %if (&track_width>=800) %then %do;
    %let label_n_cutoff=5;
%end;
%else %do;
    %let label_n_cutoff=0;
%end;

  %if &total_target_labels=0 %then %do;
      %put WARNING: No requested SNP labels remain in the local GWAS plot data.;
      %let make_even_pos=0;
  %end;
  %else %if &total_target_labels<=&label_n_cutoff %then %do;
/*	   %let dist_pct_to_cluster_pos=%sysevalf(4*&dist_pct_to_cluster_pos);*/
/*       %let dist_pct_to_cluster_pos=%sysevalf(1/&total_target_labels);*/
         %let dist_pct_to_cluster_pos=%sysevalf(0.5/&total_target_labels);
/*	   %let  fc2distant_close_labels=%sysevalf(4*&fc2distant_close_labels);*/
	   %let make_even_pos=0;
  %end;
  %else %do;
	  %let make_even_pos=1;
	  *No need to make even positions when rotation angle is set as 90;
	  %if &text_rotate_angle=90 %then %let make_even_pos=0;
  %end;

  *Horizontal top labels need more aggressive spacing control than vertical labels.;
  %if (&text_rotate_angle=0) %then %do;
      %if &total_target_labels>=3 %then %let make_even_pos=1;
      %if &total_target_labels>=3 %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,3.0));
      %if &total_target_labels>=4 %then %do;
          %let fc2distant_close_labels=%sysfunc(max(&fc2distant_close_labels,5));
          %let pct2adj4dencluster=%sysfunc(max(&pct2adj4dencluster,3));
          %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,9));
          %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,3.6));
      %end;
      %if &total_target_labels>=5 %then %do;
          %let fc2distant_close_labels=%sysfunc(max(&fc2distant_close_labels,6));
          %let pct2adj4dencluster=%sysfunc(max(&pct2adj4dencluster,4));
          %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,8));
          %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,4.2));
      %end;
      %if &track_width<700 and &total_target_labels>=4 %then %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,8));
      %if &track_width<500 and &total_target_labels>=3 %then %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,7));
  %end;
  %else %if (&text_rotate_angle>=60) %then %do;
      %if &total_target_labels>=5 %then %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,9));
      %if &total_target_labels>=7 %then %let effective_font_size4textlabels=%sysfunc(min(&effective_font_size4textlabels,8));
      %if &total_target_labels>=5 %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,2.0));
  %end;

   *Also need to adjust labels with too close positions;
  %if &track_width<700 %then %let Pct4OnlyTwoPos=0.25;
  %else %let Pct4OnlyTwoPos=0.1;

  %if (&adj_spaces_among_top_snps=1 and &total_target_labels>=2) %then %do;
   %adjust_close_positions(
   indsd=_xtag_,
   outdsd=_xtag_,
   pos_var=pos,
   new_pos_var=newpos,
   dist_pct_to_cluster_pos=&dist_pct_to_cluster_pos,
   amplification_fc=&fc2distant_close_labels,
   make_even_pos=&make_even_pos,
   Pct4OnlyTwoPos=&Pct4OnlyTwoPos,/*In case of only two positions, it is necessary to use arbitrary proportion of dist_step to separate them,
   i.e., minus and add Pct4OnlyTwoPos*dist_step and for the first and second positions, respectively*/
   pct2adj4dencluster=&pct2adj4dencluster,
   fixed_min_pos=&min_x,
   fixed_max_pos=&max_x
   ); 
   %end;
   %else %do;
	 data _xtag_;
	 set _xtag_;
	 newpos=pos;
	 run;
   %end;
   *The above macro is not good in separating these positions into distinguishable positions;
   *However, due to historical compatability, the above codes will be kept;
   *******************************************************************************************************;
   *Use the other macro to improve it, and it can be canceled if it is still not optimum;
   *Only run it when requiring the text to be rotated; 
   %if (&text_rotate_angle>0 and &adj_spaces_among_top_snps=1 and &total_target_labels>=2) %then %do;
   %put We will further optimize the space between each SNP label on the top of the gene track;
   proc sql noprint;
   select pos into: _tgt_pos_ separated by ' '
   from _xtag_ 
   order by pos;
   select &fc2distant_close_labels*0.1*(&max_x-&min_x+1)/count(*) into: sep4tgt_pos
   from _xtag_;
   %spaceAdjust(data=&_tgt_pos_, out=_xtag1_, goal=COL:, sep=&sep4tgt_pos, newvar4adjnum=newpos); 
   /* _xtag1_ follows genomic-position order, so align rows before merging. */
   proc sort data=_xtag_;
   by pos;
   run;
   data _xtag_;
   merge _xtag_(drop=newpos) _xtag1_(keep=newpos);
   run;
   %end;
   /* Preserve the planner's label centers after the legacy SAS spacing pass.
      Only label coordinates change; GWAS marker and LD positions stay intact. */
   %if %length(%superq(label_position_overrides))>0 %then %do;
   data _xtag_;
   set _xtag_;
   length _planned_token $256 _planned_snp $128;
   do _planned_i=1 to countw(symget('label_position_overrides'), ' ');
      _planned_token=scan(symget('label_position_overrides'), _planned_i, ' ');
      _planned_snp=scan(_planned_token, 1, '=');
      if upcase(strip(&var4label_scatterplot_dots))=upcase(_planned_snp) then do;
         _planned_bp=input(scan(_planned_token, 2, '='), best32.);
         if not missing(_planned_bp) then newpos=_planned_bp;
         leave;
      end;
   end;
   drop _planned_token _planned_snp _planned_i _planned_bp;
   run;
   %end;
/*   %abort 255;*/
 
   *******************************************************************************************************;
     proc sort data=_xtag_;
     by &var4label_scatterplot_dots pos;
     run;

     data _xtag_;
     set _xtag_;
     by &var4label_scatterplot_dots;
     if first.&var4label_scatterplot_dots;
     run;

     /*
       _xtag_ contains only the requested label rows.  Update their adjusted
       x positions directly in FINAL with a hash lookup.  The former
       CREATE TABLE FINAL AS SELECT ... FROM FINAL required a second complete
       438-column table plus SQL utility space and could disconnect SAS ODA
       when WORK filled.
     */
     data final;
       if _n_=1 then do;
         declare hash _label_positions(
           dataset:"_xtag_(keep=&var4label_scatterplot_dots pos newpos)",
           duplicate:"r"
         );
         _label_positions.defineKey("&var4label_scatterplot_dots", "pos");
         _label_positions.defineData("newpos");
         _label_positions.defineDone();
       end;
       modify final;
       if &var4label_scatterplot_dots^="" and pos^=. then do;
         if _label_positions.find()=0 then &lattice_subgrp_var=0;
       end;
       label top_y4label="&yaxis_label";
       replace;
     run;
   *Need to enlarge the macro var yaxis_offset4max to be 0.1;
   %let yaxis_offset4max=&yoffset4max_drawmarkersontop;
   *Get the positions of these selected markers for making vertical reflines later;
   *Note: it is important to use put to change larger number into str frist;
   *otherwise, sas will automatically round the large number to nearest number;
   *resulting into the wrong number for the newly created macro var markers_pos;
   %let markers_pos=;
   %let new_markers_pos=;
   proc sql noprint;
   select put(pos,best32.),put(newpos,best32.) into: markers_pos separated by ' ',:new_markers_pos separated by ' '
   from _xtag_;
   select count(*) into: n_marker_labels trimmed
   from _xtag_;
   select max(lengthn(strip(&var4label_scatterplot_dots)))
     into: _max_marker_label_chars trimmed
   from _xtag_;
   
   %put Your marker positions are as follows:;
   %put &markers_pos;
   %put Total marker labels requested on the top are: &n_marker_labels;

%if %sysevalf(%superq(n_marker_labels)=,boolean) %then %let n_marker_labels=0;
%if %sysevalf(%superq(_max_marker_label_chars)=,boolean) %then %let _max_marker_label_chars=0;
   %let _scatter_track_count=&totsc;
   %if %sysevalf(%superq(_scatter_track_count)=,boolean) %then %let _scatter_track_count=1;
   %if %sysevalf(&_scatter_track_count<1) %then %let _scatter_track_count=1;
   %let _scatter_y_span=%sysevalf(&max_y-&min_y+0.2);
   %if %sysevalf(&_scatter_y_span<=0) %then %let _scatter_y_span=%sysevalf(&max_y+0.2);
   %if %sysevalf(&_scatter_y_span<=0) %then %let _scatter_y_span=1;
   %let _avg_signal_span_per_track=%sysevalf(&_scatter_y_span/&_scatter_track_count);
   %let _yoffset_scale_fc=1;
   %if %sysevalf(&_avg_signal_span_per_track>4.5) %then %let _yoffset_scale_fc=%sysevalf(1+(&_avg_signal_span_per_track-4.5)*0.08);
   %else %if %sysevalf(&_avg_signal_span_per_track<3.0) %then %let _yoffset_scale_fc=%sysevalf(1-(3.0-&_avg_signal_span_per_track)*0.06);
   %if %sysevalf(&_yoffset_scale_fc<0.85) %then %let _yoffset_scale_fc=0.85;
   %if %sysevalf(&_yoffset_scale_fc>1.35) %then %let _yoffset_scale_fc=1.35;
   %let _recommended_yaxis_offset4max=&yaxis_offset4max;

   %if %sysevalf(&n_marker_labels>=1) %then %let _recommended_yaxis_offset4max=%sysfunc(max(&_recommended_yaxis_offset4max,0.08));
   %if (&text_rotate_angle=0 and %sysevalf(&n_marker_labels>=1)) %then %let _recommended_yaxis_offset4max=%sysfunc(max(&_recommended_yaxis_offset4max,0.09));
   %if %sysevalf(&n_marker_labels>=2) %then %let _recommended_yaxis_offset4max=%sysfunc(max(&_recommended_yaxis_offset4max,0.1));

/*    %if %sysevalf(&totsc>3) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.03); */
/*    %if %sysevalf(&totsc>5) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.04); */
/*    %if %sysevalf(&totsc>8) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.05); */

/*    %if %sysevalf(&track_height<700) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.03); */
/*    %if %sysevalf(&track_height<550) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.05); */
/*    %if %sysevalf(&track_height<420) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.07); */

/*    %if %sysevalf(&track_width<900) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.02); */
/*    %if %sysevalf(&track_width<700) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.03); */
/*    %if %sysevalf(&track_width<500) %then %let _recommended_yaxis_offset4max=%sysevalf(&_recommended_yaxis_offset4max+0.04); */

   %if %sysevalf(&_recommended_yaxis_offset4max>0.95) %then %let _recommended_yaxis_offset4max=0.95;
   %if %sysevalf(&_recommended_yaxis_offset4max>&yaxis_offset4max) %then %do;
      %put NOTE: Auto-increasing yaxis_offset4max from &yaxis_offset4max to &_recommended_yaxis_offset4max to reserve more top space for SNP labels.;
      %let yaxis_offset4max=&_recommended_yaxis_offset4max;
   %end;

   %if (&text_rotate_angle=0 and &n_marker_labels>=4) %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,4.0));
   %if (&text_rotate_angle=0 and &n_marker_labels>=5) %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,4.6));
   %if (&text_rotate_angle>=60 and &n_marker_labels>=5) %then %let effective_yoffset4textlabels=%sysfunc(max(&effective_yoffset4textlabels,2.2));

   *Make the top SNP label offset less sensitive to the absolute y-axis range by
   *scaling it with the observed signal span per scatter track. This keeps the
   *visual gap more stable when tracks get taller or the max -log10(P) changes.;
   %if %sysevalf(&n_marker_labels<=3) %then %do;
      %let effective_yoffset4textlabels=%sysevalf(&effective_yoffset4textlabels*&_yoffset_scale_fc);
      %if (&text_rotate_angle=0) %then %do;
         %if %sysevalf(&effective_yoffset4textlabels<0.18) %then %let effective_yoffset4textlabels=0.18;
         %if %sysevalf(&effective_yoffset4textlabels>0.90) %then %let effective_yoffset4textlabels=0.90;
      %end;
      %else %do;
         %if %sysevalf(&effective_yoffset4textlabels<0.80) %then %let effective_yoffset4textlabels=0.80;
         %if %sysevalf(&effective_yoffset4textlabels>2.80) %then %let effective_yoffset4textlabels=2.80;
      %end;
   %end;

   *Convert the needed label headroom into the raw yaxis_offset4max scale used
   *later by GTL so the reserved top region stays close to the label height.;
   *this is the key part to make the top label headroom more adaptive to the signal span and track height, thus more robust to different y-axis ranges and figure sizes.;
   *For running the code with AI, AI should be able to understand the logic of the following code;
   *and adjust the parameters and formula as needed to achieve the desired visible fraction of top labels, which is determined by the effective font size of text labels and the track height, as well as other factors such as text rotation angle, number of marker labels, average signal span per track, and figure size. The goal is to make the top label headroom more adaptive and robust to different scenarios.;
   %let _desired_visible_top_frac=%sysevalf((&effective_font_size4textlabels+1)/&track_height);
   %if (&text_rotate_angle=0) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac*1.15);
   %else %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac*0.95);
   %if %sysevalf(&n_marker_labels>1) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac+0.0025*(&n_marker_labels-1));
   %if %sysevalf(&_avg_signal_span_per_track>5.5) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac+0.002);
   %if %sysevalf(&_avg_signal_span_per_track<3.0) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac-0.0015);
   %if %sysevalf(&track_height<500) %then %let _desired_visible_top_frac=%sysevalf(&_desired_visible_top_frac+0.002);
   %if %sysevalf(&n_marker_labels=1) %then %do;
      %if %sysevalf(&_desired_visible_top_frac<0.02) %then %let _desired_visible_top_frac=0.02;
      %if %sysevalf(&_desired_visible_top_frac>0.02) %then %let _desired_visible_top_frac=0.02;
   %end;
   %else %do;
      %if %sysevalf(&_desired_visible_top_frac<0.02) %then %let _desired_visible_top_frac=0.02;
      %if %sysevalf(&_desired_visible_top_frac>0.040) %then %let _desired_visible_top_frac=0.040;
   %end;

   %let _auto_yaxis_offset4max=&_desired_visible_top_frac;
   %if %sysevalf(&_scatter_track_count>5) %then %let _auto_yaxis_offset4max=%sysevalf(&_desired_visible_top_frac*&_scatter_track_count/5);
   %if %sysevalf(&_auto_yaxis_offset4max<0.02) %then %let _auto_yaxis_offset4max=0.02;
   %if %sysevalf(&_auto_yaxis_offset4max>0.25) %then %let _auto_yaxis_offset4max=0.25;
   %if %sysevalf(&n_marker_labels<=2) %then %do;
      %if %sysevalf(&_auto_yaxis_offset4max^=&yaxis_offset4max) %then %do;
         %put NOTE: Replacing yaxis_offset4max=&yaxis_offset4max with scale-aware top-label offset &_auto_yaxis_offset4max (visible frac=&_desired_visible_top_frac, tracks=&_scatter_track_count, avg_signal_span=&_avg_signal_span_per_track).;
         %let yaxis_offset4max=&_auto_yaxis_offset4max;
      %end;
   %end;
   %else %if %sysevalf(&_auto_yaxis_offset4max>&yaxis_offset4max) %then %do;
      %put NOTE: Auto-increasing yaxis_offset4max from &yaxis_offset4max to &_auto_yaxis_offset4max with scale-aware top-label headroom (visible frac=&_desired_visible_top_frac).;
      %let yaxis_offset4max=&_auto_yaxis_offset4max;
   %end;

   /* Fit vertical labels to the longest requested marker. Font size is in
      points while track_height is a layout dimension; raster DPI must not
      change the fraction of the plot reserved for a label. */
   %if (&text_rotate_angle>=60 and &n_marker_labels>=1) %then %do;
      %let _vertical_label_frac=%sysevalf(((&_max_marker_label_chars*0.62+1)*&effective_font_size4textlabels*96/72+2*&effective_yoffset4textlabels+8)/(&track_height*0.75));
      %if %sysevalf(&_vertical_label_frac<0.04) %then %let _vertical_label_frac=0.04;
      %if %sysevalf(&_vertical_label_frac>0.45) %then %let _vertical_label_frac=0.45;
      %let yaxis_offset4max=&_vertical_label_frac;
      %put NOTE: Vertical SNP-label headroom fitted to &_max_marker_label_chars characters: offsetmax=&yaxis_offset4max.;
   %end;

   %put NOTE: Effective top-label settings: rotate=&text_rotate_angle font_size=&effective_font_size4textlabels yoffset=&effective_yoffset4textlabels yaxis_offset4max=&yaxis_offset4max avg_signal_span_per_track=&_avg_signal_span_per_track fc2distant_close_labels=&fc2distant_close_labels pct2adj4dencluster=&pct2adj4dencluster make_even_pos=&make_even_pos.;
    
%end;
%put NOTE: LATTICE_STAGE top_label_transform_complete;

*For debug;
/*data a;*/
/*set _xtag_;*/
/*run;*/
/*%abort 255;*/


*Select line pattern for highlighting markers labeled on the the top of scatterplots;
*Solid, ShortDash, MediumDash, LongDash,MediumDashShortDash, DashDashDot;
*DashDotDot, Dash, LongDashShortDash, Dot, ThinDot, ShortDashDot, MediumDashDotDot;
*or numbers from 1 (solid) to 46 which are many combinations of dashes,;
*dots, lengths and numbers of dashes, numbers and sizes of dots.;
%let reflinepattern=Dot;

*Also add the marker ids into the output figure name;
%let  vars4figurename=;
%if %length(&var4label_scatterplot_dots)>0 %then %do;
proc sql noprint;
select distinct trim(left(&var4label_scatterplot_dots)) into: vars4figurename separated by '_'
from final
where &var4label_scatterplot_dots^="";

%if %length(&vars4figurename)>100 %then %do;
   %put You var4figurename is too long:;
   %put &var4figurename;
   %put The macro will arbitrarily assign the value of macro var var4label_scatterplot for the macro var;
   %let  vars4figurename=&var4label_scatterplot_dots;
%end;

*When there are three or fewer SNPs for labeling at the top, keep those labels horizontal in the top headroom;
*Also reduce the top cell space represented by the macro var yoffset4max_drawmarkersontop from the default value 0.15 to 0.05;
*Other parameters restrict the upper and lower offset are also resetted;
%if %sysevalf(&n_marker_labels>=1) and %sysevalf(&n_marker_labels<=3) and &auto_rotate2zero=1 %then %do;
    %let text_rotate_angle=0;

/*	%let yoffset4max_drawmarkersontop=0.01;*/
	/*Setting this as 0 does not change the figure, so this parameter is not needed to be reset!*/
	/*Use the simpler horizontal-label scaling for small label sets so <=3 SNPs
      stay readable on one line within the reserved headroom. */
	%let effective_yoffset4textlabels=%sysevalf(0.55*1000/&track_height);
	%if &track_height<400 %then %let effective_yoffset4textlabels=0.55;
	%let yaxis_offset4max=%sysevalf(0.04*500/&track_height);
	%let yaxis_offset4min=%sysevalf(0.02*500/&track_height);/*This will reduce the lower offset of y-axis*/
    %put NOTE: Small top-label horizontal tuning: n_marker_labels=&n_marker_labels yaxis_offset4max=&yaxis_offset4max yaxis_offset4min=&yaxis_offset4min effective_yoffset4textlabels=&effective_yoffset4textlabels track_height=&track_height.;
%end;
%if %length(%superq(label_headroom_frac))>0 and %length(%superq(label_center_offset))>0 %then %do;
    %let yaxis_offset4max=&label_headroom_frac;
    %let effective_yoffset4textlabels=&label_center_offset;
    %put NOTE: Planned top-label headroom=&yaxis_offset4max center_offset=&effective_yoffset4textlabels.;
%end;
%end;

 *In terms of gene labels in the gene track, if a gene is too close to the right most position in the figure;
*It is necessary to move the gene label position to left to prevent the gene label is truncated in the figure;
%if (%length(&xaxis_viewmax)>0 and %length(&xaxis_viewmin)>0) %then %do;
     %let window_dist=%sysevalf(&xaxis_viewmax - &xaxis_viewmin + 1);
	 %let _maxpos_=&xaxis_viewmax;
%end;
%else %do;
     %let window_dist=%sysevalf(&max_x - &min_x + 1);
	 %let _maxpos_=&max_x;
%end;

*********************************************SAS codes to adjust gene label positions, preventing them too close to each other*********************;
/*proc sql noprint;*/
/*select max(pos1), min(pos1)into: max_pos1, :min_pos1*/
/*from final;*/
%if &track_width>=500 %then %let extra_reduce_pct=0.8;
%else %let extra_reduce_pct=1;
*This means for figure with width < 500, it will increase the 1 fold for the amplification facto;
*but for figure with width > 500 and < 750, it will keep around 0.8 fold for the amplification facto;
*in terms of figure with width >750, it will keep around 0.8*0.5 fold for the amplification factor;
data final ;
set final;
pfactor=IFC(length(grp_label)<3,0,length(grp_label))/4;
if pfactor>5 then pfactor=5;
*Further adjust it by figure track_width by comparing it to the optimized figure with width 450;
pfactor=pfactor*500/&track_width;
*If track_width>600, it is necessary to reduce the factor 2 folder;
if &track_width>750 then pfactor=0.5*pfactor;
if grp_label^="" and (&_maxpos_ - pos1+1)/&window_dist<((1+pfactor)*&move_right_genetxt_pct) then do;
      *Also move the gene label by its length;
	   _pos1_=pos1-&extra_reduce_pct*&window_dist*&move_right_genetxt_pct*pfactor;
end;
else do;
	  _pos1_=pos1;
end;
run; 
/*%abort 255;*/

*This only works for making gene bed scatter plots with the yval_var, which is log10P;
%Check_VarnamesInDsd(indsd=final,Rgx=&yval_var.1,exist_tag=Hasvar4y);
%if %length(&Hasvar4y)>0 %then %do;
*Further adjust the gene lable x-axis positions if two gene labels are in the same row and have distance less than designated pct of the whole window;
%put NOTE: LATTICE_STAGE gene_label_adjust_begin;
*Further adjust the gene lable x-axis positions if two gene labels are in the same row and have distance less than designated pct of the whole window;
data final_gene;
set final(keep=grp_label grp1 &yval_var.1 _pos1_ pfactor);
where grp_label^="";
run;
proc sort;by &yval_var.1 _pos1_;run;

data final_gene;
set final_gene;
lag_pos1=lag(_pos1_);
if first.&yval_var.1 then do;
 lag_pos1=.;
end;
else do;
   if  (_pos1_ - lag_pos1+1)/&window_dist<(pfactor*&move_right_genetxt_pct)  then lag_pos1_adj=lag_pos1-&extra_reduce_pct*&window_dist*&move_right_genetxt_pct*pfactor;
end;
by &yval_var.1;
run;
*Update only affected gene-label positions in place.  This avoids recreating
 the full FINAL table through a self-referential PROC SQL join.;
data final_gene_lookup;
  set final_gene(keep=&yval_var.1 lag_pos1 lag_pos1_adj);
  where lag_pos1^=. and lag_pos1_adj^=.;
  _pos1_=lag_pos1;
  *Reuse PFActor, which already exists in FINAL, as the hash return slot.  A
   MODIFY step cannot enlarge an existing observation with a new variable.;
  pfactor=lag_pos1_adj;
  keep &yval_var.1 _pos1_ pfactor;
run;

data final;
  if _n_=1 then do;
    declare hash _gene_positions(dataset:"final_gene_lookup", duplicate:"r");
    _gene_positions.defineKey("&yval_var.1", "_pos1_");
    _gene_positions.defineData("pfactor");
    _gene_positions.defineDone();
  end;
  modify final;
  pfactor=.;
  if _gene_positions.find()=0 and pfactor^=. then _pos1_=pfactor;
  replace;
run;

proc datasets library=work nolist;
  delete final_gene final_gene_lookup;
quit;
%end;
%put NOTE: LATTICE_STAGE gene_label_adjust_complete;

*Need to obtain the minimum and maximum values to decide whether all of values of heatmap_var are postive or negative;
%let min_heatmap_var=-999;
%let max_heatmap_var=999;
%if &makedotheatmap=1 and %length(&heatmap_var)>0 %then %do;
  %put NOTE: LATTICE_STAGE heatmap_normalize_begin;
  proc sql noprint;
  select min(%unquote(&heatmap_var)) into: min_heatmap_var
  from final;
  select max(%unquote(&heatmap_var)) into: max_heatmap_var
  from final;

  data final;
  set final;
  *Reset all values <heatmap_min_neg_val or >heatmap_max_pos_val to be heatmap_min_neg_val or heatmap_max_pos_val, specifically;
 %if %sysevalf(&heatmap_min_neg_val>&min_heatmap_var) and %sysevalf(&min_heatmap_var<0) %then %do;
    %let min_heatmap_var=&heatmap_min_neg_val;
	if &heatmap_var<&heatmap_min_neg_val then &heatmap_var=&heatmap_min_neg_val;
 %end;
  %if %sysevalf(&heatmap_max_pos_val<&max_heatmap_var) and %sysevalf(&max_heatmap_var>0) %then %do;
      %let max_heatmap_var=&heatmap_max_pos_val;
	if &heatmap_var>&heatmap_max_pos_val then &heatmap_var=&heatmap_max_pos_val;
 %end;
  run;
%end;
%put NOTE: LATTICE_STAGE heatmap_normalize_complete;


/* This relabels the variable newpos as Position in the final figure. */
data final;
set final;
*Update the x-axis label, which might be revised if the macro is not used for drawing GWAS local Manhattan plot;
/* label newpos="%trim(%left(%sysfunc(prxchange(s/^chr/Chromosome /,1,&chr_name)))) (hg19)"; */
label newpos="%trim(%left(%sysfunc(prxchange(s/^chr/Chromosome /,1,&chr_name))))";
*This will remove the legend in the figure for dots that are with missing value of old_y;
*The value 1 would be used as group number to match with its corresponding char label in the figure legend;
/*if old_y=. then old_y=&Other_num_grpval;*/
*The above fails to exclude groups with missing numeric group value;
*keeping these old_y as missing would exclude them in the final figure legend; 
*The following code is just for reminding of the above fact;
%if %length(&Other_num_grpval)>0 %then %do;
if old_y=. then old_y=&Other_num_grpval;
*it is necessary to re-assign missing value to these old_y when the &yval_var is missing;
if &yval_var=. then old_y=.;
%end;
run;

*Only draw CNVs in highlow plots based on their length>1;
data final;
set final;
if not (&Variant_Length_Var>1) then do;
 &st_var=.;&end_var=.;
end;
run;
*If end_var are all missing, it means there are no CNVs for running the highlow plot;
%iscolallmissing(dsd=final,colvar=&end_var,outmacrovar=NoCNVs);

****************************************End of SAS codes to adjust gene label positions, preventing them too close to each other***************;

*****************************************************************************************************************;
/*
proc export data=final outfile="final.txt" dbms=tab replace;
run;
*/

*documentation for adjusting axis for layout overlay;
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatug/p1pqfzgbuzbpkzn1mrbzhgggvhkz.htm;
*see line dash pattern here:;
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0er4dg9tojp05n1sf7maeqdz1d8.htm;
proc template;
define statgraph Bedgraph;
dynamic _chr _pos _value _G;
begingraph / designwidth=&track_width designheight=&track_height
       %*Use customized colors;
       %if %length(&dataContrastCols)>0 %then %do;
             dataContrastColors=( &dataContrastCols )  ATTRPRIORITY=color
        %end;
        ;
 %if %length(%superq(plot_title))>0 %then %do;
   entrytitle "&plot_title";
 %end;
 
 /*Define colors for dots by group in the scatter plot*/
 %if &lattice_subgrp_var ne %then %do;     
      discreteattrmap name="dotgrpname" / ignorecase=true;
        /*If the symbol is used in the scatterplot statment, the following symbol specification will be overwritten!*/
        value "Neg" /
          markerattrs=GraphData1(color=%scan(&scatterdotcols,1,%str( )) symbol=circlefilled)
          lineattrs=GraphData1(color=red pattern=solid);
        value "Pos" /
          markerattrs=GraphData2(color=%scan(&scatterdotcols,2,%str( )) symbol=trianglefilled)
          lineattrs=GraphData2(color=green pattern=shortdash);   
      enddiscreteattrmap;
      /*The attrvar and var have the same variable name here!*/
      discreteattrvar attrvar=&lattice_subgrp_var var=&lattice_subgrp_var
        attrmap="dotgrpname";
   %end;
 
   /*When the following condition is true, the above discreteattrmap "dotgrpname" will be replaced with a new rangeattrmap!*/
   %if &makedotheatmap=1 and %length(&heatmap_var)=0 %then %do;
    /*Define colors for dots by group in the heatmap plot*/
      rangeattrmap name="dotheatmap";
         range &min_old_y - &max_old_y / 
         rangeAltColorModel=(CXFFFFB2 CXFED976 CXFEB24C CXFD8D3C CXFC4E2A CXE31A1C CXB10026);
         range OTHER / rangeAltColor=black;
         range MISSING / rangeAltColor=Lime;
       endrangeattrmap;
      /*The attrvar and var have the same variable name here!*/
      rangeattrvar attrvar=old_y_attrvar var=old_y
        attrmap="dotheatmap";
   
   %end;

    %if &makedotheatmap=1 and %length(&heatmap_var)>0 %then %do;
      /*Define colors for dots by group in the heatmap plot*/
      rangeattrmap name="dotheatmap";
		%if %sysevalf(&min_heatmap_var <=0) and %sysevalf(&max_heatmap_var>0) %then %do;
         range &heatmap_min_neg_val  - 0    / rangealtcolormodel=(&heatmap_Neg_rangealtcolormodel);
         range 0 - &heatmap_max_pos_val / rangealtcolormodel=(&heatmap_Pos_rangealtcolormodel) ;
		%end;
		%else %if (%sysevalf(&min_heatmap_var >= 0) and %sysevalf(&max_heatmap_var>0)) %then %do;
         range 0 - &heatmap_max_pos_val / rangealtcolormodel=(&heatmap_Pos_rangealtcolormodel) ;
		%end;
		%else %if (%sysevalf(&min_heatmap_var <0) and %sysevalf(&max_heatmap_var<=0)) %then %do;
         range &heatmap_min_neg_val  - 0    / rangealtcolormodel=(&heatmap_Neg_rangealtcolormodel);
		%end;
		%else %do;
			%put You minimum color response variable is %left(%trim(&min_heatmap_var)) and maximum value for the variable is %left(%trim(&max_heatmap_var));
			%put They are not both postive and negative or either postive or negative;
			%put WARNING: Falling back to the non-heatmap scatter coloring mode for this panel.;
      %let makedotheatmap=0;
		%end;

         range OTHER / rangeAltColor=black;
         range MISSING / rangeAltColor=Lime;

       endrangeattrmap;
      /*The attrvar and var have the same variable name here!*/
      rangeattrvar attrvar=heatmap_var_attrvar var=%unquote(&heatmap_var)
        attrmap="dotheatmap";

	%end;

    %if %length(&ld_heatmap_var)>0 %then %do;
      rangeattrmap name="ldheatmap";
        range 0 - 1 / rangealtcolormodel=(&ld_heatmap_colormodel);
        range OTHER / rangealtcolor=gray;
        range MISSING / rangealtcolor=white;
      endrangeattrmap;
      rangeattrvar attrvar=ld_r2_attrvar var=&ld_heatmap_var attrmap="ldheatmap";
    %end;

   %if "&color_resp_vartype"="C" and &makedotheatmap=0 %then %do;
	    discreteattrmap name="dotgrpname" / ignorecase=true;
        /*If the symbol is used in the scatterplot statment, the following symbol specification will be overwritten!*/
       enddiscreteattrmap;
      /*The attrvar and var have the same variable name here!*/
       discreteattrvar attrvar=old_y_attr_var var=old_y
        attrmap="dotgrpname";
   %end;
        
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10 ;
         /*the offsetmin and offsetmax affect the offset area for y axis;*/
       *The adding of walldisplay=none will remove yaxis and other borders, but the yaxis should be kept;
/*         layout overlay/WALLDISPLAY=none yaxisopts=(*/
	       *Note: the label option will be the real functional section to update the yaxis label;
	       *Keep the requested y-axis title visible for both standard scatter and heatmap local-GTF panels;
          layout overlay/yaxisopts=(label="&yaxis_label"	
 /*                     only provide tickvalues will prevent other features, such as ticks, in the yaxis            */
/*                      need to add label to display y label; also remove ticks when makeheatmapdotintooneline=1   */
                        display=(%if &makeheatmapdotintooneline=0 %then %do; 
                                   tickvalues
                                 %end;
                                   label)
 /*                     type=linear offsetmin=0.05 offsetmax=0.05     */
                    %if &totsc>20 %then %do;
/*                         type=linear offsetmin=%sysevalf(&yaxis_offset4min*&totsc/200)  */
/*                         offsetmax=%sysevalf(&yaxis_offset4max*&totsc/200) */
/*                      The offset min and max will affect the upper and lower parts of the tracks   */
                        offsetmin=%sysevalf(&yaxis_offset4min*20/&totsc) 
                        offsetmax=%sysevalf(&yaxis_offset4max*20/&totsc)
						%put offsetmax for y-axis is set as %sysevalf(&yaxis_offset4max*15/&totsc);
                    %end;
					%else %if &totsc>10 %then %do;
                        offsetmin=%sysevalf(&yaxis_offset4min*13/&totsc) 
                        offsetmax=%sysevalf(&yaxis_offset4max*13/&totsc)
                        %put offsetmax for y-axis is set as %sysevalf(&yaxis_offset4max*10/&totsc); 
                    %end;
                    %else %if &totsc>5 %then %do;
                        offsetmin=%sysevalf(&yaxis_offset4min*8/&totsc) 
                        offsetmax=%sysevalf(&yaxis_offset4max*8/&totsc)                    
						%put offsetmax for y-axis is set as  %sysevalf(&yaxis_offset4max*5/&totsc) ;
                    %end;
                    %else %do;
                        offsetmin=&yaxis_offset4min 
                        offsetmax=&yaxis_offset4max                    
                        %put offsetmax for y-axis is set as &yaxis_offset4max ; 
                    %end;
/*			linearopts=(minorticks=false tickvaluelist=(&y_axis_values) )      */
                         type=linear
                         linearopts=(
                         %*expand the min and max value with 0.1 when only drawing gene track;
                         %if &NotDrawScatterPlot=1 %then %do;
                         %*it is hard to optimize;
                         viewmax=-&offsety viewmin=%sysevalf(&min_y-&offsety)
                         %end;
                         %else %do;
/*                          viewmax=%sysevalf(&max_y+&offsety*2/&totsc) */
/*                          viewmin=%sysevalf(&min_y-&&offsety*2/&totsc) */
/*                      This part will affect the union of y-axis, with othe optimized value 1 to be added or removed from max and min, respectively               */
                         viewmax=%sysevalf(&max_y+0.1)
                         viewmin=%sysevalf(&min_y-0.1)                         
                         %end;
                         %if &use_custom_y_ticks=1 %then %do;
                         minorticks=false tickvaluelist=(&y_axis_values) tickdisplaylist=(&ylabelsmacro_var)
                         %end;
                         %else %do;
                         minorticks=false
                         %end;
/*This is the key part to make the y-axis as desinged: read https://www.lexjansen.com/nesug/nesug12/bb/bb04.pdf*/
                        %if &yaxis_auto_ticks=0 %then %do;
                         tickvaluefitpolicy=none
                         %end;
                         )
                       )
                        xaxisopts=(
                        linearopts=(
                        
                        %if %length(&xaxis_viewmin)>0 %then %do;
                        viewmin=&xaxis_viewmin
                        THRESHOLDMIN=0 
                        %end;
                        %else %do;
                        viewmin=&min_x
                        %end;
                        
                        %if %length(&xaxis_viewmax)>0 %then %do;
                        viewmax=&xaxis_viewmax
                        THRESHOLDMAX=0
                        %end;
                        %else %do;
                        viewmax=&max_x
                        %end;
                        
                        tickvalueformat=best32.) 
/*                      offsetmin=0.05 offsetmax=0.05       */
                        offsetmin=&xaxis_offset4min offsetmax=&xaxis_offset4max
                        );
 
 %if %length(&var4label_scatterplot_dots)>0 %then %do;
*Add labels for specific dots in scatterplots, but it is impossible to rotate text using the procedure scatterplot;
/*        scatterplot x=pos y=&yval_var/ MARKERCHARACTER=&var4label_scatterplot_dots MARKERCHARACTERPOSITION=topright*/
/*                                   MARKERCHARACTERATTRS=(color=black size=&grp_font_size*/
/*                                   style=normal weight=normal);*/
*textplot gives the more control on the manipulation of text;
      %if (&label_dots_once_on_top=1 and %length(&var4label_scatterplot_dots)>0 and &NotDrawScatterPlot=0) %then %do;
      
          *Ensure firstly add vertical reference line for these marker positions;
          %do mki=1 %to %ntokens(&markers_pos);
/*            referenceline x=%scan(&markers_pos,&mki) /lineattrs=(color=&reflinecolor4selecteddots*/
/*                                                      pattern=thindot thickness=1);*/
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatgraph/n1jn4duv8s510xn1y2nlbefm0p46.htm;
*https://blogs.sas.com/content/graphicallyspeaking/2018/01/15/advanced-ods-graphics-draw-statements;
*The drawline is better with the drawspace controling the line positions;
/*              drawline x1=%scan(&markers_pos,&mki,%str( ))  y1=0 x2=%scan(&markers_pos,&mki,%str( ))  y2=%sysevalf(&max_y-0.5) / drawspace=datavalue*/
/*                                                       lineattrs=(color=&reflinecolor4selecteddots pattern=&reflinepattern thickness=1);*/
/*              drawline x1=%scan(&markers_pos,&mki,%str( ))  y1=%sysevalf(&max_y-0.5) x2=%scan(&new_markers_pos,&mki,%str( ))  y2=%sysevalf(&max_y) / drawspace=datavalue*/
/*                                                       lineattrs=(color=&reflinecolor4selecteddots pattern=&reflinepattern thickness=1);                                       */
		      drawline x1=%scan(&markers_pos,&mki,%str( ))  y1=0 x2=%scan(&markers_pos,&mki,%str( ))  y2=%sysevalf(&max_y*&snp_line_split_ratio) / drawspace=datavalue
                                                       lineattrs=(color=&reflinecolor4selecteddots pattern=&reflinepattern thickness=1);
              drawline x1=%scan(&markers_pos,&mki,%str( ))  y1=%sysevalf(&max_y*&snp_line_split_ratio) x2=%scan(&new_markers_pos,&mki,%str( ))  y2=%sysevalf(&max_y) / drawspace=datavalue
                                                       lineattrs=(color=&reflinecolor4selecteddots pattern=&reflinepattern thickness=1);    
          %end;   
          
          *POSITION=BOTTOM | BOTTOMLEFT | BOTTOMRIGHT | CENTER | LEFT | RIGHT | TOP | TOPLEFT | TOPRIGHT | keyword-column;
          *specifies the position of the text value with respect to the location of the data point.;
          *When text_rotate=90, use position=right;
          *When text_ortate=0, use text=center;
		  %if &text_rotate_angle>0 %then %do;
          textplot x=newpos y=top_y4label text=&var4label_scatterplot_dots/ 
              rotate=&text_rotate_angle position=right textattrs=(size=&effective_font_size4textlabels)
              POSITIONOFFSETX=0 POSITIONOFFSETY=&effective_yoffset4textlabels;
		  %end;
	      %else %do;
          textplot x=newpos y=top_y4label text=&var4label_scatterplot_dots/ 
              rotate=&text_rotate_angle position=center textattrs=(size=&effective_font_size4textlabels)
              POSITIONOFFSETX=0 POSITIONOFFSETY=&effective_yoffset4textlabels;
		  %end;
           
       %end;
       %else %do;
          textplot x=pos y=&yval_var text=&var4label_scatterplot_dots/ rotate=&text_rotate_angle position=center textattrs=(size=&effective_font_size4textlabels)
                                                                                                                   POSITIONOFFSETX=0 POSITIONOFFSETY=&effective_yoffset4textlabels;
        %end;
 %end;
 
	%if (&label_dots_once_on_top=1 and %length(&var4label_scatterplot_dots)>0) %then %do;
	   referenceline y=&max_y /lineattrs=(color=&refline_color pattern=1 thickness=&refline_thickness);
	%end;                        
                        /* Need to add this into linearopts later: tickdisplaylist=(&y_grp_values)*/
		 %do xti=1 %to %sysfunc(countw(&genegrp_ords));
      %let i=%scan(&genegrp_ords,&xti);
	       %if &i=1 %then %do;
                     *Add group labels, but failed due to text statement is not available for proc template;
                     *text x=&pos&i y=&yval_var.&i text=group_label;
                     *If the scatterplot is not wanted, we can exclude the reference line at 0;
                     %if %eval(&NotDrawScatterPlot=0) %then %do;
		              referenceline y=0 /lineattrs=(color=&refline_color pattern=1 thickness=&refline_thickness);
		             %end;     
						%if &min_y<0 %then %do;
/* 						  %do _yi_=&min_y %to -1; */
/* 		       referenceline y=&_yi_ /lineattrs=(color=black pattern=thindot thickness=1); */
/* 					          %end; */
                          %let _yneg_n=%eval(%sysfunc(countc(&yvals4reflines,%str( ))) + 1);
                          %do  _yneg_i=1 %to &_yneg_n;
                            *Do not draw reference line when NotDrawScatterPlot=1;
                            *Note: - is added before the number;
                            %if &NotDrawScatterPlot=0 %then %do;
                             %if &totsc<=5 %then %do;
                            		 %if &draw_grid4y=1 %then %do;
                                  referenceline y=-%scan(&yvals4reflines,&_yneg_i,%str( )) /lineattrs=(color=&refline_color pattern=thindot thickness=1);
                                  %end;
                             %end;
                            %end;
                          %end;
						%end;
												
						
						%do yi=1 %to &max_y;
						    %if &totsc<=5 and &totsc>=2 %then %do;
                        %if &draw_grid4y=1 %then %do;
							            referenceline y=&yi /lineattrs=(color=&refline_color pattern=thindot thickness=1);
                         %end;
						    %end; 
						    *fix a bug when mk_fake_axis_with_updated_func=1 by getting rid of the last unwanted refline;
						    *also need to restrict it with %sysfunc(countw(&fake_refline_values))=2;
/* 						    %if (&mk_fake_axis_with_updated_func=1 and %sysfunc(countw(&fake_refline_values,ad))=1) %then  */
/* 						    %let fytot=%sysevalf(%sysfunc(countw(&fake_refline_values,ad)) - 0); */
/* 						    %else %let fytot=%sysfunc(countw(&fake_refline_values,ad)); */
/*                          The above uses countw without the modifiers ad for alphabetic and digital words will results in wrong result*/
                            %let fytot=%ntokens(&fake_refline_values);
/*                             Maybe due to the overwritten value of global variable fake_refline_values, fytot is also as 1 when there are actually 2 scatterplot*/ 
                           *Here it should be &fytot>=1 but not &totsc>=2;
                          %if &totsc>2 %then %do;
                          /*Only when there are more than 1 scatterplot, it will draw additional thick reference line to separate scatterplots*/
						    %do xxi=1 %to &fytot;
                              %if &yi=%scan(&fake_refline_values,&xxi) %then %do;
		                         referenceline y=&yi /lineattrs=(color=&refline_color pattern=1 thickness=&refline_thickness);
		                         
							  %end;
						    %end;
						  %end;
						 %end;
		   %end;
					    *If the _y&i dsd dose not exist, skip it;
					    %if %sysfunc(exist(work._y&i._)) %then %do;
									   %if %eval(&i=1) %then %do;
												 *make the 1str grp use group=&grp_var.&i and enable its color more transparent;
										     *Excludeing missing groups from the legend by adding the option: INCLUDEMISSINGGROUP=FALSE;
               seriesplot x=pos&i y=&yval_var.&i / group=&grp_var.&i connectorder=xaxis
			                          /*To use custom color, add color=black or other inside the lineattrs block*/
			                         %if %length(&color_resp_var)>0 %then %do;
									 lineattrs=(pattern=SOLID thickness=&linethickness color=%scan(&fixedcols4tracksunderscatter,1,%str( )))
									 %end;
									 %else %do;
                                      lineattrs=(pattern=SOLID thickness=&linethickness)
									  %end;
                                      name="series&i" datatransparency=0.5	INCLUDEMISSINGGROUP=FALSE
												%end;
												%else %if (%eval(&i>=2)) %then %do;
												 *Make other grps use dark color, but it is not possible, as group is needed;
               seriesplot x=pos&i y=&yval_var.&i /connectorder=xaxis group=&grp_var.&i 
			                           /*To use custom color, add color=black or other inside the lineattrs block*/
			                         %if %length(&color_resp_var)>0 %then %do;
									 lineattrs=(pattern=SOLID thickness=&linethickness color=%scan(&fixedcols4tracksunderscatter,2,%str( )))
									 %end;
									 %else %do;
                                      lineattrs=(pattern=SOLID thickness=&linethickness)
									  %end;
                                      name="series&i" datatransparency=0.2

												%end;

          %end;                            
          ;
         %end;

 /*This highlow plot is specifically designed for drawing CNV*/
/*https://www.lexjansen.com/pharmasug-cn/2019/HW/Pharmasug-China-2019-HW06.pdf*/
*Not draw highlow lines before scatter dots;
/* highlowplot y=&yval_var high=&end_var low=&st_var /*/
/*	     group=&lattice_subgrp_var*/
/*         datatransparency=0.4*/
*        type=line  lineattrs=(thickness=10pt color=darkorange pattern=dash);
/*        type=line  lineattrs=(&highlow_line_cmd)*/
/*        highcap=NONE lowcap=NONE; */
	
*Use &grp_var to color dots in scatterplot;         
/*          scatterplot x=pos y=&yval_var/group=&grp_var name="sc"  */
/*                                        markerattrs=( */
/*                                        symbol=circlefilled size=&dotsize  */
/*                                        ); */
*Use &scatter_grp_var to color dots in scatterplot;
*Failed, use &grp_var, again;
*Need to have a new group var &lattice_subgrp_var to color them;
 %if &makedotheatmap=1 and %length(&heatmap_var)=0 %then %do;
*Note: the lattice_subgrp was used to determine whether to draw colorbar;
*the markercolorgradient will overwrite the symbol feature in markerattrs;
*filledoutlinedmarkers can be changed as true to add black dot outline;
*When choosing to draw dotheatmap;
*The group=&lattice_subgrp_var is not required!;
         scatterplot x=pos y=&yval_var/      
                                       markercolorgradient=old_y_attrvar
                                       filledoutlinedmarkers=false
                                       name="sc" 
                                       markerattrs=(
                                       symbol=&scattermarker_symbol size=&dotsize
                                       );
/*        continuouslegend "sc"/title="Dot value"; */
/*        Only draw integer ticks for the colorbar legend */
          continuouslegend "sc"/title="&heatmap_legend_title" integer=true;
 %end;
 %if &makedotheatmap=1 and  %length(&heatmap_var)>0 %then %do;
*Note: the lattice_subgrp was used to determine whether to draw colorbar;
*the markercolorgradient will overwrite the symbol feature in markerattrs;
*filledoutlinedmarkers can be changed as true to add black dot outline;
*When choosing to draw dotheatmap;
*The group=&lattice_subgrp_var is not required!;
         scatterplot x=pos y=&yval_var/      
                                       markercolorgradient=heatmap_var_attrvar
                                       filledoutlinedmarkers=false
                                       name="sc" 
                                       markerattrs=(
                                       symbol=&scattermarker_symbol size=&dotsize
                                       );
/*        continuouslegend "sc"/title="Dot value"; */
/*        Only draw integer ticks for the colorbar legend */
          continuouslegend "sc"/title="&heatmap_legend_title" integer=true;
 %end;
 %else %do;
         scatterplot x=pos y=&yval_var/ 
                                %if &lattice_subgrp_var ne and "&color_resp_var"="" %then %do;
                                       group=&lattice_subgrp_var
                                %end;
								%else %if 	"&color_resp_var"^="" and "&color_resp_vartype"="C" %then %do;
									   group=old_y INCLUDEMISSINGGROUP=FALSE
								%end;
                                       name="sc" 
                                       markerattrs=(
                                       symbol=&scattermarker_symbol size=&dotsize);
%end;   

 %if %length(&var4mark_ld_scatterplot_dots)>0 %then %do;
   *Overlay LD-linked points after the ordinary association scatter layer.;
   textplot x=pos y=&yval_var text=&var4mark_ld_scatterplot_dots /
     position=center textattrs=(color=&ld_marker_color size=%sysevalf(&dotsize+2) weight=bold);
 %end;

 %if %length(&ld_heatmap_var)>0 %then %do;
   *Opt-in LocusZoom-like LD layer. Its sequential scale is independent of the association Z-score scale.;
   scatterplot x=pos y=_LD_PLOT_Y_ /
     markercolorgradient=ld_r2_attrvar filledoutlinedmarkers=true name="ldsc"
     markerattrs=(symbol=circlefilled size=%sysevalf(&dotsize+1));
   continuouslegend "ldsc" / title="&ld_heatmap_legend_title" orient=horizontal
     location=inside halign=right valign=top;
 %end;

 /*This highlow plot is specifically designed for drawing CNV*/
/*https://www.lexjansen.com/pharmasug-cn/2019/HW/Pharmasug-China-2019-HW06.pdf*/
*Draw highlow lines before scatter dots, enabling the line cover these scatter data points;
%if &NoCNVs=0 %then %do;
 highlowplot y=&yval_var high=&end_var low=&st_var /
	     group=&lattice_subgrp_var
         datatransparency=0.5
/*        type=line  lineattrs=(thickness=10pt color=darkorange pattern=dash)*/
        type=line  lineattrs=(&highlow_line_cmd)
        highcap=NONE lowcap=NONE;  
%end;
                                       
       %if &add_grp_anno=1 %then %do;                              
         *Make sure to add the test label at the end, otherwise, these labels will be blocked by other layers;
         *MARKERCHARACTERPOSITION=CENTER | TOP | BOTTOM | LEFT | RIGHT | TOPLEFT | TOPRIGHT | BOTTOMLEFT | BOTTOMRIGHT;
/*         scatterplot x=pos1 y=&yval_var.1 / MARKERCHARACTER=grp_label MARKERCHARACTERPOSITION=left */
/*         use text customized y values to label these genes                                         */
         scatterplot x=_pos1_ y=_y_ / MARKERCHARACTER=grp_label MARKERCHARACTERPOSITION=topright
                                    MARKERCHARACTERATTRS=(color=black size=&grp_font_size 
                                    style=&grp_anno_font_type weight=normal);
       %end;
       
 %if %length(&ordered_sc_grpnames)>0 %then %do;      
       *Add scatter group header and adjust header x-axis position by length;
       scatterplot x=avgpos y=header_yval / markercharacter=header_grp 
       markercharacterattrs=(color=black size=%sysevalf(2+&grp_font_size)  weight=normal) 
       markercharacterposition=top;
  %end;    

      endlayout; 
	  sidebar /align=bottom;
			/*Note: only series1 is used to combine with sc in the discretelegend;
			  This is because seriesplot used the group options to draw all grps with
			  different colors in the 1st &grp_var1, which contain all gene grps;
			*/
 %if &makedotheatmap=1 %then %do;
      /*Remove the legend for gene tracks to save space and also keep the figure with the same height as the number of genes will affect the heights of data areas*/
      /*discretelegend "series1" /border=false valueattrs=(color=black size=&grp_font_size weight=normal style=&grp_anno_font_type); */
 %end;
 %else %do;
/*	  discretelegend "sc" "series1"*/
 %if %length(&color_resp_var)>0 %then %do;
 *Remove gene legends when &color_resp_var is supplied, as these colors tend to be the same;
 discretelegend "sc" 	/border=false valueattrs=(color=black size=&grp_font_size weight=normal style=&grp_anno_font_type); 
 %end;
 %else %do;
 *Do not need these redudant gene legends;
 %if &rm_gene_legend %then %do;
      discretelegend "sc" /border=false valueattrs=(color=black size=&grp_font_size weight=normal style=&grp_anno_font_type); 
  %end;
  %else %do;
     discretelegend "sc" "series1"	/border=false valueattrs=(color=black size=&grp_font_size weight=normal style=&grp_anno_font_type); 
  %end;
 %end;

 %end;
/*   Only add legends for scatter plot and gene track*	  
/* 	  discretelegend "sc" %do i=1 %to &max_ord; */
/*                           "series&i" */
/*                          %end; */

 %if %length(&var4mark_ld_scatterplot_dots)>0 %then %do;
      entry "&ld_marker_legend_symbol LD-linked SNP" / textattrs=(color=&ld_marker_color size=&grp_font_size weight=normal);
 %end;

	  endsidebar;
   endlayout;
endgraph;
end;
run;


*Change dir into the termporary work dir for saving svg figure;
%if &sysscp=WIN %then %do;
   %let workdir=%sysfunc(getoption(work));
%end;
%else %do;
   %let workdir=%sysfunc(pathname(HOME));
%end;

data _null_;
rc=dlgcdir("&workdir");
run;

%if %length(&vars4figurename)>0 %then %do;
     %if %length(&vars4figurename)>32 %then %let vars4figurename=%scan(&vars4figurename,1,%str(_))_and_others;
     %let outimagename=&vars4figurename._%trim(%left(&chr_name))_&st_var%trim(%left(&min_x))_&end_var%trim(%left(&max_x));
%end;
%else %do;
     %let outimagename=&yval_var.Chr%trim(%left(&chr_name))_&st_var%trim(%left(&min_x))_&end_var%trim(%left(&max_x));
%end;
%let outimage_rand_suffix=%RandBetween(1,100);

%if not %symexist(local_gtf_ods_html5) %then %do;
  %put The final figure is put here:;
  %put &workdir/&outimagename._f&outimage_rand_suffix..&fig_fmt;
%end;
/* The SAS ODA wrappers already open HTML5 at the requested DPI. Opening HTML
   here would render the same large graph a second time in another destination. */
%if not %symexist(local_gtf_ods_html5) %then %do;
  ods html image_dpi=&image_dpi;
%end;
ods graphics on /
reset=all
outputfmt=&fig_fmt 
imagename="&outimagename._f&outimage_rand_suffix" 
noborder
MAXOBS=100000000
GROUPMAX=50000
;

*Add format for directions of &lattice_subgrp_var;
proc format;
value direction_fmt 
0='Neg' 
/*
-999 - < 0 = 'Neg'
*/
1='Pos'
/*
0< - <1 = 'Pos'
1< - 999 = 'Pos'
*/
;
run;

/*Does not work as expected;
ods graphics on/reset=all;
%ModStyle(
parent=journal,
colors=red blue green
);
*The above will generate the Newstyle;
ods html style=Newstyle;
*/

*Draw the final figure with data set final and the template BedGraph;
proc sgrender data=WORK.final template=BedGraph;
dynamic _chr="&chr_var";

%if %length(&color_resp_var)>0 %then %do;
  %if "&color_resp_vartype"="C" %then %do;
   format old_y y2x4colresp.;
  %end;
%end;
%else %if (%length(&heatmap_var)>0 and &makedotheatmap=1) %then %do;
  *No need to format when makeing heatmap;
%end;
%else %do;
   format &lattice_subgrp_var direction_fmt.;
%end;
run;


*****************************************************************************************************************;
*Clean temporary datasets;
*Need to delete these _y: datasets, as there are used by the above proc template macro scripts;
%if &debug=0 %then %do;
proc datasets nolist;
delete _y: y1for: _xtag_ _single_ _dsdin_ X1_: scgrpnames Header_dsd Final_fmt;
run;
%end;

*Ensure the input &bed_dsd is not changed;
data &bed_dsd;
set &bed_dsd._org;
run;
proc sql noprint;
drop table &bed_dsd._org;
run;

%put Lattice gscatter plot is completed!;
%put ;

%mend;

/* END companion/research/advanced_figures/sources/definitions/Lattice_gscatter_over_bed_track.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/Manhattan4DiffGWASs_png.sas */
%macro Manhattan4DiffGWASs(
dsdin=,/*Input GWAS dataset with multiple GWAS p variables put in columns; it is ideal to have sorted GWAS by numeric chr and position*/
pos_var=,/*Position variable for markers, such as SNPs*/
chr_var=,/*Chromosome variable for markers, such as SNPs; it is better to have numberic chr var as input*/
P_var=,/*The P var for the 1st GWAS that is put at the bottom of the final manhattan plot; can be the only GWAS input*/
Other_P_vars=, /*Leave it empty for a single-GWAS plot, or provide other GWAS P vars in order for making manhattan plots from botton to up*/
logP=1,/*Provide value 1 to indicate the need of performing -log10 caculation for input P_var; Make sure the P_var and Other_P_vars are in the same format!*/
gwas_thrsd=7.3,/*Use it to draw significance reference line in each GWAS track*/
thrsd_line_color=gray,
dotsize=2,/*The dot size for scatter plots*/
_logP_topval=10, /*Top -log10P value to truncate GWAS signals and also restrict the max yaxis value of each GWAS track;
Make sure to input EVEN number for the macro, as the macro separate ticks by step 2!*/
y_axix_step=2,/*Customize the step for all y-axis tikets*/
fig_width=1200,
fig_height=500,
fontsize=3,
y_axis_label_size=, /*Optional y-axis label font size; default uses fontsize*/
y_axis_value_size=, /*Optional y-axis tick-value font size; default uses fontsize*/
gwas_label_names=, /*Optional pipe-delimited labels matching P_var followed by Other_P_vars*/
gwas_label_x_pct=50, /*Graph-percent x position for GWAS track labels*/
gwas_label_y_frac=0.89, /*Within-track y position as fraction of _logP_topval*/
gwas_label_size=1.0, /*Black foreground label size in percent units*/
gwas_label_halo_size=1.0, /*White underlay label size in percent units, ensure it is the same as the gwas_label_size!*/
gwas_label_angle=0, /*Angle for GWAS track labels*/
flip1stGWAS_signal=1, /*When providing value 1, which will draw the 1st GWAS at the bottom in reverse order for the yaxis, 
which means the most significant association will be put close to bottom;
provide value 0 to draw the 1st GWAS in vertical mode!*/
refline_color_4zero=gray, /*Color the manhattan bottom line*/
rm_signals_with_logP_lt=0.5, /*To make the manhattan plot have reference line at association signal of zero,
it is better to remove associaiton signal logP for all GWASs less than the cutoff*/
use_uniq_colors=1, /*Draw scatter plots with different colors for chromosomes;
provide value 0 to use SAS default color scheme;*/
uniq_colors=,/*Provide customized uniq colors, such as cx0072bd and others with the prefix cx;
If left empty, the default unique colors included in the macro will be used!*/
gwas_sortedby_numchrpos=0, /*Ideally the input GWAS dsdin should be sorted by numchr and pos;
if the GWAS dsdin is not, the macro will sort it accordingly but will require more memory and disk space*/
outputfigname=Manhattan, /*a prefix used to label the output figure*/
plot_title=, /*Optional visible title for the plotted statistic and color encoding.*/
angle4xaxis_label=40, /*Adjust the angle of xaxis group labels*/
Use_scaled_pos=1, /*Default is to draw manhattan plot with fake positions by group in even distance;
Provide value 1 to draw the plot in scaled and uneven distance relative to its real position values!
This will be helpful when draw top hits local manhattan plots!
*/
sep_chr_grp=0, /*Default is not to add lines to separate x-axis chromosomal groups;
Provide value 1 to add lines to separate each chromosomal group*/ 
xgrp_y_pos=-1, /*Asign the y-axis value for all x-axis group labels;
It is necessary to adjust the value if the default value is out of range;
Try to use -1 to replace -1.5 if the above issue occurred!*/
yoffset_setting=%str(offset=(0.5,0.5)), /*This macro var is used to extend the bottom and upper y-axis;
which is especially helpful when the position of x-axis group labels assigned by xgrp_y_pos is 
out of the default offset of y-axis */

/*Important parameters for drawing local Manhattan pltos*/
draw_local_Manhattan=0,/*Default is to draw genome-wide Manhattan plot; if supplying value 1, the macro will draw local
Manhattano around target SNPs when the macro var target_SNPs is provided or top hits if the macro var target_SNPs
is empty and the macro var top_hit_thresd is supplied with specific association p threshold, such as p < 1e-6*/
snp_var=rsid,/*It is necessary to have snp_var supplied when drawing local Manhattan plot*/
snp_gene_splitter=:,/*In case the gene name for the snp is also supplied to the snp_var, the macro
will split the snp_var into two string, with the first is snp and the 2nd is genename for it, which will
be plotted at the bottom of the figure as x-axis labels for different snp mahattan plot*/
target_SNPs=,/*Default is empty; please provide rsid that can be matched with the snp macro variable*/
Keep_order_of_target_SNPs=0, /*Draw local Manhattan plot according to the order of target SNPs
Note: need to set this macro with value 1 if drawing local Manhattan plots for target SNPs or top hits, 
which means if either target_SNPs or top_hit_thresd is not empty, please assign value 1 to this macro var!
When draw genome-wide Manhattan plots, it is required to assign value 1 to this macro var.*/
top_hit_thresd=,/*provide a p value threshold to only draw local Manhattan plot for the smallest 
top hit around a specific genomic window,such as p < 1e-6 within a window of 1e7 bp*/
dist4get_smallest_top_hit=1e7, /*Select the smallest top SNP around a genomic window of the supplied distance in bp*/
only_get_top_hit4n_th_gwas=0, /*The parameter enables the macro to focus on top hits from specific gwas represented by
its order starting from 1 to n for the 1st gwas and other gwass inferred by their supplied P variables; the default value 0 means
to query all gwas top hits; if only want to query top hits from the 1 gwas, please supply value 1, and this applicable to 
other gwass if the correct numeric order for the gwas is supplied here!*/
LD_SNPs2mark_scatterplot_dots=, /*Space-delimited high-LD rsIDs overlaid on every GWAS track.*/
LD_marker_symbol=*,
LD_marker_color=black,
LD_display_mode=none,
LD_r2_values=,
LD_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F,
LD_heatmap_legend_title=%str(LD r2)
);

%local n_other_pvars n_gwas_pvars;
%let n_other_pvars=%sysfunc(countw(%superq(Other_P_vars),%str( )));
%let n_gwas_pvars=%eval(&n_other_pvars+1);

/**fake data;*/
/*data manhattan ;*/
/*Fake_position=1; */
/*do &chr_var=1 to 22;*/
/*do _n_=1 to ( 1e6 - &chr_var * 10000 ) - 1 by 1000 ;*/
/*   Fake_position + _n_ / 1e6 ;*/
/*   logp = -log( ranuni(2)) ;*/
/*   output ;*/
/*end;*/
/*end;*/
/*run;*/

%if %length(&Other_P_vars)=0 %then %do;
    %put NOTE: Other_P_vars is empty, so the macro will draw a single-GWAS Manhattan plot using only &P_var;
%end;

%if %varexist(ds=&dsdin,var=&chr_var) = 0 %then %do;
					 %put Input chr var &chr_var does not exit!;
           %abort 255;
%end;

%if %varexist(ds=&dsdin,var=&pos_var) = 0 %then %do;
					 %put Input position var &pos_var does not exit!;
           %abort 255;
%end;

%if %varexist(ds=&dsdin,var=&P_var) = 0 %then %do;
					 %put Input P value var for the 1st GWAS does not exit!;
           %abort 255;
%end;



*Subset GWAS data for target regions with top association signals passed specific p threshold;
*or just draw the local Manhattan for these target SNPs with specific window size; 
%if &draw_local_Manhattan=1 %then %do;
       *Draw local Manhattan plot for target SNPs;
			 %if 	(%length(&target_SNPs)>0 and %length(&top_hit_thresd)=0) %then %do;
					%put We will extract association signals around these target snps and draw local Manhattan plot;
           %put Your target SNPs are &target_SNPs;
          *Get target SNPs; 
          %get_tgt_hits4Manhattan(
           dsdin=&dsdin,
           snp_var=&snp_var,
           chr_var=&chr_var,
           pos_var=&pos_var,
           p_var=&P_var,
           dsdout=_tgthits_,
           target_snps=&target_snps, 
           keep_target_snps_order=&Keep_order_of_target_SNPs,
           dist4get_uniq_top_hit=&dist4get_smallest_top_hit 
           );
          *Note: the above macro will generate new variable tag_snp and a global macro variable _chr_colors_;
          *which will be used to draw Manhattan plots by chr, and it is necessary to reset these macro var values for making local Manhattan plot;
          %let dsdin=_tgthits_;
           *Draw local Manhattan plots by sorted order of target SNPs;
           %let chr_var=tag_snp;
           %if &Keep_order_of_target_SNPs=1 %then %do;
           *Draw local Manhattan plots by keeping the original order of target SNPs;
           %let chr_var=num_grps;
           %end;

          %let uniq_colors=&_chr_colors_;
       %end;
       %*Draw local Manhattan plot for top hits passed a specific p threshold;
       %else %do;
           %if %length(&top_hit_thresd)=0 %then %let top_hit_thresd=1e-6;
           %let top_snps=;
           %local _mh_;
		   %do _mh_= 1 %to &n_gwas_pvars;
			 %if &only_get_top_hit4n_th_gwas=0 %then %do;
             %get_top_hits4Manhattan(
              dsdin=&dsdin,
              snp_var=&snp_var,
              chr_var=&chr_var,
             pos_var=&pos_var,
             p_var=%scan(&P_var &Other_P_vars,&_mh_,%str( )),
             dsdout=_tophits_&_mh_,
             p_thrsd=&top_hit_thresd, 
            dist4get_uniq_top_hit=&dist4get_smallest_top_hit
             );
/*             *Note: the above macro will create new variable tag_snp and a global macro var _top_snps_ that will be used to capture these top SNPs;*/
/*             %let top_snps=&top_snps &_top_snps_;*/
			%end;
			%else %if (&_mh_=&only_get_top_hit4n_th_gwas) %then %do;

             %get_top_hits4Manhattan(
              dsdin=&dsdin,
              snp_var=&snp_var,
              chr_var=&chr_var,
             pos_var=&pos_var,
             p_var=%scan(&P_var &Other_P_vars,&_mh_,%str( )),
             dsdout=_tophits_&_mh_,
             p_thrsd=&top_hit_thresd, 
            dist4get_uniq_top_hit=&dist4get_smallest_top_hit
             ); 
 
			%end;
           %end;
					 %put We will extract associaiton signals around these top SNPs within a genomic window of &dist4get_smallest_top_hit bp that pass the p value threshold of &top_hit_thresd;
           %put These top SNPs are &top_snps;
            data tophits_all;
            set _tophits_:;
            run;
           *Reset these macro var values for making local Manhattan plot;
            %let dsdin=tophits_all;
            *Draw local Manhattan plots by sorted order of target SNPs;
            %let chr_var=tag_snp;
            proc sql noprint;
            select distinct cls into: uniq_colors separated by ' '
            from tophits_all 
            order by tag_snp;
       %end;
%end;

*Check &chr_var type for preparing of making alternative var _chr_ for plotting;
*Note: will create a global var: var_type, which can be used in other macro;
%check_var_type(
dsdin=&dsdin,
var_rgx=&chr_var
);
%put Created a global var for chr, its type of which is &var_type;
/*%put the macro chr_var is &chr_var;*/
/*%abort 255;*/

*For char &chr_var;
%if "&var_type"="2" %then %do;
/*This step will take a lot of disk space*/
data &dsdin;
set &dsdin;
frq=1;
run;
%if &Keep_order_of_target_SNPs=1 %then %do;
/*For ordered local Manhattan panels, assign a stable numeric group id directly
  instead of depending on a generated format catalog entry.*/
%let ordered_target_label_var=&chr_var;
data _chr_map_;
  length &chr_var $32767;
  if 0 then set &dsdin(keep=&chr_var);
  declare hash seen();
  seen.defineKey("&chr_var");
  seen.defineData("&chr_var","_chr_");
  seen.defineDone();
  do until (eof);
    set &dsdin(keep=&chr_var) end=eof;
    if seen.check() ne 0 then do;
      _chr_+1;
      seen.add();
      output;
    end;
  end;
  stop;
run;

proc sql;
create table &dsdin as
select a.*, b._chr_
from &dsdin as a
left join _chr_map_ as b
  on a.&chr_var=b.&chr_var
;
quit;
%end;
%else %do;
/*use the frq for sorting by total number of data points*/
%format_xaxis_with_numeric_order(
dsdin=&dsdin,
Xaxis_vars=&chr_var,
new_Xaxis_var=_chr_,
Var4sorting_Xaxis=frq,
function4sorting=count,
descending_or_not=0,
dsdout=&dsdin,
createdfmtname=Xaxis_var_label);
%end;

/*Use the following when the above failed*/
/* This will change char chr labels into numeric ones */
/* Used when it is necessary */

/* %chr_format_exchanger( */
/* dsdin=&dsdin, */
/* char2num=1, */
/* chr_var=&chr_var, */
/* dsdout=&dsdin); */

*Just try to reuse the above function, the function4sorint is not useful;
*so asign missing value for it;
%let chr_var=_chr_;
%end;


*real data;
%if %eval("&gwas_thrsd"="") %then %do;
%let gwas_thrsd=7.3;
%end;

*Sorting the gwas will slow down the macro;
/*
proc sort data=&dsdin;
by &chr_var &pos_var;
run;
*/

%if &gwas_sortedby_numchrpos=0 %then %do;
proc sort data=&dsdin;
by &chr_var &pos_var;
run;
%end;

%if %sas_dsd_exist(sasdsd=&dsdin)=0 or %totobsindsd(mydata=&dsdin)=0 %then %do;
    %put Your input dataset &dsdin does not exist or is empty;
    %abort 255;
%end;
 

%let nrows=%rows_in_sas_dsd(test_dsd=&dsdin);
%put There are &nrows in your dataset;

%if &Use_scaled_pos=0 %then %do;
*Here we will use fake positions with an even gap to draw manhattan plot;
/*For EWAS;*/
%if (&nrows lt 100000 and &nrows gt 30000) %then %do;
data manhattan ;
set &dsdin;
Fake_position=1; 
Fake_position + _n_ / 1e2 ;/*This part will affect the Xaxis dramatically*/;
/*where &chr_var between 1 and 24;*/
/*where &chr_var >=1;*/
run;
%end;
/*For local EWAS or GWAS;*/
%else %if (&nrows lt 30000 and &nrows gt 4000) %then %do;

data manhattan ;
set &dsdin;
Fake_position=1; 
Fake_position + _n_ /2 ;/*This part will affect the Xaxis dramatically*/;
/*where &chr_var between 1 and 24;*/
/*where &chr_var >=1;*/
run;
%end;
/*For local EWAS or GWAS;*/
%else %if &nrows le 4000 %then %do;
data manhattan ;
set &dsdin;
Fake_position=1; 
Fake_position + _n_ ;/*This part will affect the Xaxis dramatically*/;
/*where &chr_var between 1 and 24;*/
/*where &chr_var >=1;*/
run;
%end;
/*For GWAS*/
%else %do;
data manhattan ;
set &dsdin;
Fake_position=1; 
Fake_position + _n_ / 1e3 ;/*This part will affect the Xaxis dramatically*/;
/*where &chr_var between 1 and 24;*/
/*where &chr_var >=1;*/
run;
%end;

%end;

%else %do;
*Here we will use fake positions with scaled and uneven gap  to draw manhattan plot;
%add_fake_pos_by_grp4nonnegvars(
dsdin=&dsdin,
axis_var=&pos_var,
axis_grp=&chr_var,
new_fake_axis_var=Fake_position,
dsdout=manhattan,
axis_step=1,
concise_output=1,
reset_1st_value_as_one=1
);
%end;


data manhattan;
set manhattan;
/* Keep a SNP when any displayed GWAS track has a P value. In merged-wide
   tables, meta and differential values can occupy distinct allele rows;
   filtering on the primary track alone silently empties the other track. */
if n(of &P_var &Other_P_vars)=0 then delete;
%if (&logP=1) %then %do;
logp=-log10(&P_var);
%end;
%else %do;
logp=&P_var;
%end;
run;

*Sorting the gwas will slow down the macro;
/*
proc sort data=manhattan;
by &chr_var Fake_position;
run;
*/

%if &gwas_sortedby_numchrpos=0 %then %do;
proc sort data=manhattan;
by &chr_var Fake_position;
run;
%end;
 
*find maximum value for the x-axis, store in a macro variable;
proc sql noprint;
select 1.005*ceil(max(Fake_position)) into :maxbp 
from manhattan;
quit;
 
* 
find mean of BP within each chromosome (C)
used later to position x-axis labels
;

*A potential bug here especially when there are a lot of SNPs with missing p values;
*were removed from the data set before calculating the mean of these positions;
*Try to generate a temporary data set;
proc sort data=manhattan(keep=&chr_var Fake_position) out=_manhattan_ nodupkeys;
by &chr_var Fake_position;
run;
proc sql;
create table _manhattan_ as
select *
from _manhattan_
group by &chr_var
having Fake_position=min(Fake_position) or Fake_position=max(Fake_position);
*If the above invite some bugs, it is feasible to use the data set manhattan to replace _manhattan_;
proc summary data=_manhattan_ nway;
%if &Keep_order_of_target_SNPs=1 %then %do;
*Draw local Manhattan plots by keeping the original order of target SNPs;
/*class &chr_var tag_snp;*/
*No need to add tag_snp as &chr_var is updated as tag_snp;
class &chr_var;
%end;
%else %do;
class &chr_var;
%end;
var Fake_position;
/*output out=mbp mean=;*/
/*output out=mbp mean= min=min max=max;*/
output out=mbp mean=;
run;

%if &Keep_order_of_target_SNPs=1 %then %do;
proc sql;
create table mbp as
select a.*, b.&ordered_target_label_var
from mbp as a
left join _chr_map_ as b
  on a.&chr_var=b._chr_
;
quit;
%end;

*The _mid_ is the same as the mean position;
/*data mbp;*/
/*set mbp;*/
/*_mid_=(max-min)/2 + min;*/
/*run;*/

 
* annotate data set used to add x-axis labels
"manually" add the frame around the graph
possibly add a horizontal reference line
;
data anno ;
length color $10. text $64. style $20.;
*Note: the position will decide where to put the text;
*position '1': put text under the position and left adjusted;
*position '2': put text at the middle of the position and left adjusted;
*position '3': put text above the position and left adjusted;
*position '4': put text under the position and center adjusted;
*see other useful positions, such as A, B, C, D, E, F;
*and <,+, and >, and 7,8,9;
*at: https://documentation.sas.com/doc/es/pgmsascdc/v_053/graphref/annotate_position.htm;
%if "&var_type"="2" or &Keep_order_of_target_SNPs=1 %then %do;
retain position '4' xsys ysys '2' y &xgrp_y_pos function 'label' text 'xx'  angle &angle4xaxis_label;
%end;
%else %do;
*Key part to put the genomewide xgroup labels, such as 1,2,3,...,20 at the center of the position on the x-axis;
%*put the xgroup labels at the center but one cell lower than the position;
/* retain position '8' xsys ysys '2' y 0 function 'label' text 'xx' ; */
%*Put the xgroup labels at the center of the position;
/* retain position '+' xsys ysys '2' y 0 function 'label' text 'xx' ; */
%*Text baseline half cell below location;
/* retain position '5' xsys ysys '2' y 0 function 'label' text 'xx' ; */
%*Half cell below location;
retain position 'E' xsys ysys '2' y 0 function 'label' text 'xx';
%end;
do until (last1);
  %if &Keep_order_of_target_SNPs=1 %then %do;
  *Draw local Manhattan plots by keeping the original order of target SNPs;
/*   set mbp (keep = Fake_position &chr_var  tag_snp) end=last1;*/
   *No need to add tag_snp as &chr_var is tag_snp when keep_order_of_target_SNPs is true;
     set mbp (keep = Fake_position &chr_var &ordered_target_label_var) end=last1;
  %end;
  %else %do;
   set mbp (keep = Fake_position &chr_var) end=last1;
  %end;
   x = round(Fake_position) ;
   *This step can be modified to remove the x-axis group labels by asigning empty str to text;
   %if &Keep_order_of_target_SNPs=1 %then %do;
     *For ordered local grouped Manhattan plots, keep numeric ordering in _chr_
      while restoring the original SNP:gene label for the bottom box.;
     text = strip(&ordered_target_label_var);
   %end;
   %else %if "&var_type"="2" %then %do;
   *text="";
    text=put(&chr_var,Xaxis_var_label.);
/*       text=cat(&chr_var);*/
   %end;
   %else %do;
      text = cat(&chr_var);
      if text="20" or text="22"  then text=" ";
   %end;
   output;
end;
 
* top of frame;
%if &n_gwas_pvars > 1 %then %do;
xsys = '1'; ysys = '1'; function = 'move'; x = 0; y=100; output;
xsys = '2'; function = 'draw'; x = &maxbp ; output;
%end;
* bottom of frame;
xsys = '1'; ysys = '1'; function = 'move'; x = 0; y=0; output;
xsys = '2'; function = 'draw'; x = &maxbp ; output;
 
* horizontal reference line (if needed for 5x10-08);
%if &n_gwas_pvars > 1 %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&_logP_topval; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=1; size=3; color="&refline_color_4zero";output;
%end;

* Explicit zero-reference line for the first/bottom GWAS track.
* This is separate from the frame border because axis offsets used for SNP/gene
* labels can move the visible plotting region away from the graph edge.
%if &draw_local_Manhattan=1 %then %do;
* When drawing local Manhattan plot, it is better to have the reference line for zero association signals;
%if (&flip1stGWAS_signal=0) %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=0; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=1; size=3; color="&refline_color_4zero";output;
%end;
%else %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&_logP_topval; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=1; size=3; color="&refline_color_4zero";output;
%end;
%end;

*Note: only when &_logP_topval>&gwas_thrsd, the macro can draw these gwas threshold reference line;
%if (&flip1stGWAS_signal=0) %then %do;
%if %sysevalf(&_logP_topval>&gwas_thrsd) %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&gwas_thrsd; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=2; size=1; color="&thrsd_line_color";output;
%end;
%end;
%else %do;
%if %sysevalf(&_logP_topval>&gwas_thrsd) %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&_logP_topval-&gwas_thrsd; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=2; size=1; color="&thrsd_line_color";output;
%end;
%end;

%do ri=1 %to &n_other_pvars;

*For lines in the middle separating different scatter plots, use large line size to draw lines;
%if &ri < &n_other_pvars %then %do;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&_logP_topval+&_logP_topval*&ri; output;
xsys = '2'; function = 'draw'; x = &maxbp ;  line=1; size=3; color="&refline_color_4zero";output;
%end;

%if %sysevalf(&_logP_topval>&gwas_thrsd) %then %do;
*For lines at the top and bottom, use lighter line size to draw lines;
xsys = '1'; ysys = '2'; function = 'move'; x = 0; y=&gwas_thrsd+&_logP_topval*&ri; output;
xsys = '2'; function = 'draw'; x = &maxbp ; line=2; size=1; color="&thrsd_line_color";output;
%end;

%end;

* Add GWAS variable names in the middle of each stacked GWAS track;
%do _gwas_label_i_=1 %to &n_gwas_pvars;
  label_x = &maxbp / 2;
  label_y = (&_gwas_label_i_ - 1) * &_logP_topval +
            min(&_logP_topval - 0.8, max(0.8, &_logP_topval * &gwas_label_y_frac));
  %if %superq(gwas_label_names) ne %then %do;
    text = "%qscan(%superq(gwas_label_names),&_gwas_label_i_,|)";
  %end;
  %else %do;
    text = "%scan(&P_var &Other_P_vars,&_gwas_label_i_,%str( ))";
  %end;

  * A white label underlay gives a readable halo over dense point clouds;
  * when 'a' is used for when, the label will be drawn after all the points are drawn, which can make sure the label is not covered by any points;
  xsys = '2';
  ysys = '2';
  hsys = '3';
  when='a';
  function = 'label';
  x = label_x;
  y = label_y;
  color = 'white';
  style = 'Albany AMT';
  size = &gwas_label_halo_size;
  position = '5';
  angle = &gwas_label_angle;
  output;

  * Dark label centered over the white underlay;
  function = 'label';
  x = label_x;
  y = label_y;
  color = 'black';
  style = 'Albany AMT';
  size = &gwas_label_size;
  position = '5';
  angle = &gwas_label_angle;
  when='a';
  output;
%end;
drop label_x label_y;

run;

*Further split text annotation if it contains the split char ":";
*https://communities.sas.com/t5/Graphics-Programming/Splitting-text-in-two-lines-using-annotion-dataset/td-p/246199;
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/graphref/annotate_position.htm;
data anno;
retain str_len_diff 0;
set anno;
text0=trim(left(text));
if prxmatch("/[^&snp_gene_splitter]+:[^&snp_gene_splitter]+/",text) and function='label' then do;
	  do ti=1 to min(3,countw(text0,"&snp_gene_splitter"));
		 text=scan(text0,ti,"&snp_gene_splitter");
		 str_len_diff=length(scan(text0,1,"&snp_gene_splitter"));

		 *half cell above location right aligned;
		 %if &angle4xaxis_label=90 %then %do;
		 if ti=1 then do;
            position='B';
            y=&xgrp_y_pos;
            hsys='3';
            size=max(1,&fontsize*0.80);
            style='Albany AMT';
         end;
		 %end;
		 %else %do;
		 if ti=1  then position='2';
		 *one cell below location centeral aligned;
		 %end;

		 else if ti=2 then do;
            %if &angle4xaxis_label=90 %then %do;
             position='E';
             y=&xgrp_y_pos;
             hsys='3';
             size=max(1,&fontsize*0.72);
			*Use annotate relative-position placement for the second rotated line,
             which matches the behavior of the original macro better than
             forcing explicit x/y offsets.;
			 %end;
			 %else %do;
		     position='+';*original location central alignment; 
			 %end;
			 *See availabel SAS font style: https://documentation.sas.com/doc/en/vwbgraphref/v_001/n0c8945h7o2kmrn1h0uehmio2i6j.htm;
			 style='ITALIC';
			str_len_diff=str_len_diff-length(scan(text0,2,"&snp_gene_splitter"))+1;
			*str_len_diff=round(str_len_diff/2);
			if str_len_diff>0 then do;
			  *text=resolve('%AddSpaces4str(str='||text||',add2end=1,nspaces='|| str_len_diff ||',char4space=-)');
			end;
		 end;
		 else do;
            *Third component, when supplied, is the chromosome name.
             Place it to the right of the vertical gene symbol.;
			%if &angle4xaxis_label=90 %then %do;
            position='E';
            y=&xgrp_y_pos;
            hsys='3';
            size=max(1,&fontsize*0.66);
            *Convert the gene-label font height to fake-position units so
             the chromosome label has its own column to the right.;
            x=x+1.3*&maxbp*max(1,&fontsize*0.72)*&fig_height/(100*&fig_width);
			%end;
			%else %do;
            position='+';
			%end;
            style='Albany AMT';
		 end;
		 output;
	  end;
end;
else output;
drop text0 ti;
run;

 
* reset all then set some graphics options;
%let max_yaxis_val=%sysevalf(&n_other_pvars*&_logP_topval + &_logP_topval);
*If put reset=all inside the command of goptions, the title will be removed;
*It is necessary to reset all here, otherwise, the figure may be distorted;
*Albany AMT is equivalent to Arial in SAS;
* destination for the plot;
filename gout "~/&outputfigname..png";

goptions reset=all ftext="Albany AMT" htext=&fontsize gunit=pct 
         dev=png xpixels=&fig_width ypixels=&fig_height gsfname=gout gsfmode=replace;

 
/* Clear inherited titles and draw a requested title with a compact font. */
%if %length(%superq(plot_title))>0 %then %do;
  title1 h=1.3 "&plot_title";
%end;
%else %do;
  title1;
%end;
title2;
title3;
footnote1;
 
* let SAS choose the colors;
* use h=5 to set dot size for the plot;
%if &use_uniq_colors=0 %then %do;
symbol1 v=dot r=46 h=&dotsize;
%end;
%else %do;
 %if %length(&uniq_colors)=0 %then %do;
      *Use default unique colors;
      %uniqcolors;
  %end;
   %else %do;
     *Use customized unique colors;
     %uniqcolors(inputcolors=&uniq_colors);
    %end;
%end;

* two alternating colors;
* gray-scale;
*%twocolors(gray33,graycc);
* blue and blue-green;
*%twocolors(cx2C7FB8,cx7FCDBB);
 
*If the y_axix_step is larger than the top _logp_topval;
*Use step value 2 instead;
%if %sysevalf(2*&y_axix_step)>=&_logp_topval %then %do;
					 %put Your assigned y-axis step value &y_axix_step is too large and even larger than half of the top association value;
           %put The macro will reset the y-axis step value as 2!;
           %let y_axix_step=2;
%end;

%if %length(&y_axis_label_size)=0 %then %let y_axis_label_size=&fontsize;
%if %length(&y_axis_value_size)=0 %then %let y_axis_value_size=&fontsize;

* suppress drawing of any x-axis feature;
axis1 value=none major=none minor=none label=none style=0;
* rotate y-axis label and asign font as f='Albany AMT';
axis2 label=(angle=90 "-Log10(p)" f=Arial h=&y_axis_label_size) 
     order=(0 to  &max_yaxis_val by &y_axix_step)	 &yoffset_setting
      value=(f=Arial h=&y_axis_value_size
             %do _pi_=0 %to &n_other_pvars;
                %if (&flip1stGWAS_signal=1 and &_pi_=0) %then %do;
                  %do _ti_=&_logp_topval %to &y_axix_step %by -&y_axix_step;
                      "&_ti_"
                   %end;              
                 %end;
                 %else %do;
                  %do _ti_=0 %to %sysevalf(&_logp_topval-&y_axix_step) %by &y_axix_step;
                      "&_ti_"
                   %end;
                  %end;
               %end;
                ' '
                  );
 
* use PROC GPLOT to create the plot;
*Add format for customized &chr_var labels;
*Make sure to remove nolegend;

data manhattan;
set manhattan;
length _LD_SNP_MARK_ $8 _LD_COLOR_ $16;
_LD_SNP_MARK_='';
_LD_R2_=.;
%if %length(&LD_SNPs2mark_scatterplot_dots)>0 and %upcase(&LD_display_mode) ne NONE %then %do;
if findw(upcase("&LD_SNPs2mark_scatterplot_dots"),upcase(strip(&snp_var)),' ')>0
  then _LD_SNP_MARK_="&LD_marker_symbol";
%end;
%if %length(&LD_r2_values)>0 and
    (%upcase(&LD_display_mode)=HEATMAP or %upcase(&LD_display_mode)=BOTH) %then %do;
%do _li_=1 %to %ntokens(&LD_r2_values);
  %let _ld_pair_=%scan(&LD_r2_values,&_li_,%str( ));
  if upcase(strip(&snp_var))=upcase("%scan(&_ld_pair_,1,%str(:))") then
    _LD_R2_=input("%scan(&_ld_pair_,2,%str(:))",best32.);
%end;
if not missing(_LD_R2_) then do;
  if _LD_R2_<0.5 then _LD_COLOR_="%scan(&LD_heatmap_colormodel,1,%str( ))";
  else if _LD_R2_<0.8 then _LD_COLOR_="%scan(&LD_heatmap_colormodel,2,%str( ))";
  else _LD_COLOR_="%scan(&LD_heatmap_colormodel,-1,%str( ))";
end;
%end;
*Further remove signals with logP<1.3, which will save space and prevent the reference lines covered by these signals with logP<1.3;
if logP<&rm_signals_with_logP_lt then logP=.;
if logp>&_logP_topval then logp=&_logP_topval;

%if (&flip1stGWAS_signal=1) %then %do;
logp=&_logP_topval-logp;
%end;


%do _mi_=1 %to &n_other_pvars;
 logp&_mi_=-log10(%scan(&Other_P_vars,&_mi_,' '));
if logP&_mi_<&rm_signals_with_logP_lt then logP&_mi_=.;
 if logp&_mi_>&_logP_topval then logp&_mi_=&_logP_topval ;
if logp&_mi_^=. then logp&_mi_=logp&_mi_+&_logP_topval*&_mi_;
%end;

run;

%if %length(&LD_SNPs2mark_scatterplot_dots)>0 and
    (%upcase(&LD_display_mode)=MARKERS or %upcase(&LD_display_mode)=BOTH) %then %do;
data _ld_snp_anno;
  set manhattan(where=(not missing(_LD_SNP_MARK_)));
  length function $8 text $40 color $16 position $1 style $12;
  retain xsys '2' ysys '2' function 'label' text "&LD_marker_symbol" color "&LD_marker_color"
         position '5' style 'Arial' size 1.6;
  x=Fake_position;
  array _ld_logp_[*] logp logp1-logp%ntokens(&Other_P_vars);
  do _ld_i_=1 to dim(_ld_logp_);
    y=_ld_logp_[_ld_i_];
    if not missing(y) then output;
  end;
  keep x y xsys ysys function text color position style size;
run;
proc append base=anno data=_ld_snp_anno force;
run;
data _ld_snp_legend;
  length function $8 text $40 color $16 position $1 style $12;
  xsys='1'; ysys='1'; x=1; y=98; function='label'; position='6';
  text=cats("&LD_marker_symbol",' High-LD SNP'); color="&LD_marker_color"; style='Arial'; size=1.2;
run;
proc append base=anno data=_ld_snp_legend force;
run;
%end;

%if %length(&LD_r2_values)>0 and
    (%upcase(&LD_display_mode)=HEATMAP or %upcase(&LD_display_mode)=BOTH) %then %do;
data _ld_r2_anno;
  set manhattan(where=(not missing(_LD_R2_)));
  length function $8 text $40 color $16 position $1 style $12;
  xsys='2'; ysys='2'; function='label'; text='o'; color=_LD_COLOR_;
  position='5'; style='Arial'; size=1.8; x=Fake_position;
  array _ld_logp_[*] logp logp1-logp%ntokens(&Other_P_vars);
  do _ld_i_=1 to dim(_ld_logp_);
    y=_ld_logp_[_ld_i_]; if not missing(y) then output;
  end;
  keep x y xsys ysys function text color position style size;
run;
proc append base=anno data=_ld_r2_anno force; run;
data _ld_r2_legend;
  length function $8 text $80 color $16 position $1 style $12;
  xsys='1'; ysys='1'; function='label'; position='6'; style='Arial'; size=1.0;
  x=68; y=98; text="&LD_heatmap_legend_title"; color='black'; output;
  x=78; text='o 0-0.5'; color="%scan(&LD_heatmap_colormodel,1,%str( ))"; output;
  x=86; text='o 0.5-0.8'; color="%scan(&LD_heatmap_colormodel,2,%str( ))"; output;
  x=95; text='o 0.8-1'; color="%scan(&LD_heatmap_colormodel,-1,%str( ))"; output;
run;
proc append base=anno data=_ld_r2_legend force; run;
%end;

proc transpose data=manhattan out=manhattan(rename=(col1=logP) drop=_name_);
var logp:;
by &chr_var Fake_position;
run;

*Get the max position for each chr;
proc sql noprint;
select distinct Fake_position into: min_fk_pos separated by ' '
from manhattan
group by &chr_var
having fake_position=min(fake_position);
*Remove the first element in the list;
%select_element_range_from_list( 
list=&min_fk_pos, 
st=2, 
end=%ntokens(&min_fk_pos), 
sublist=new_min_fk_pos, 
sep=%str( ) 
); 


%if "&var_type"="2" or &Keep_order_of_target_SNPs=1 %then %do;

/*Note: the offset setting will make the legend move left when value is negative!*/
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/graphref/p0anvu6ux4d0ijn1mt06fn9yl0wx.htm#p18f31f18e6elan1ge5bb2pjiv34;
*Note: asign empty string for the label of the legend;
legend1 across=10 down=2 repeat=1 label=(height=4 position=top justify=center ' ')
        value=(height=2) shape=symbol(2,2) offset=(1pct)
        position=(bottom center outside);
*The offset=(0,0)cm or offset=(2pct) will affect the left position of the legend;
*See how to customize legend:;
*https://support.sas.com/resources/papers/proceedings/proceedings/forum2007/163-2007.pdf;

%if &sep_chr_grp=1 %then %do; 
%let maxbp=&maxbp &new_min_fk_pos;
%end;

proc gplot data=manhattan;
plot logp*Fake_position=&chr_var 
 /  
                 haxis = axis1
                 vaxis = axis2
                 href  = &maxbp 
                 annotate = anno
                nolegend
		            noframe
/*		         legend=legend1*/
;
%if &Keep_order_of_target_SNPs^=1 %then %do;
format &chr_var Xaxis_var_label.;
%end;
label Fake_position="Groups"
      &chr_var="Legends of groups";
run;

*Also keep a copy of the dataset for further plotting with the macro;
/*
data _tgthits_;
set _tgthits_;
drop tag_snp;
run;
*/

%end;

%else %do;
proc gplot data=manhattan;
plot1 logp*Fake_position=&chr_var
 / 
                 haxis = axis1
                 vaxis = axis2
                 href  = &maxbp
                 annotate = anno
                 nolegend
		         noframe
;
run;
%end;

*This will enable the macro generate one figure by proc gplot in SAS OnDemand for Academics;
*Otherwise, there would be two duplicated Manhattan plots;
/* %return; */
*return does not work, and only quit dose!;
%put After successfully generate manhattan plot, the macro will quit to prevent from two duplicated Manhattan plots printed!;
quit;

%mend;
%macro twocolors(c1,c2);
%do j=1 %to 23 %by 2;
symbol&j v=dot c=&c1;
symbol%eval(&j+1) v=dot c=&c2;
%end;
%mend;
%macro uniqcolors(inputcolors=);

%if %length(&inputcolors)=0 %then %do;
/*https://support.sas.com/content/dam/SAS/support/en/books/pro-template-made-easy-a-guide-for-sas-users/62007_Appendix.pdf*/
*For standard RGB chars generated by inkscape, it is necessary to remove the last two chars ff and put cx at the beginning;
symbol1 v=dot h=&dotsize c=cx0072bd;
symbol2 v=dot h=&dotsize c=cxd95319;
symbol3 v=dot h=&dotsize c=cxedb120;
symbol4 v=dot h=&dotsize c=cx7e2f8e;
symbol5 v=dot h=&dotsize c=cx77ac30;
symbol6 v=dot h=&dotsize c=cx4dbeee;
symbol7 v=dot h=&dotsize c=cxa2142f;
symbol8 v=dot h=&dotsize c=cx0072bd;
symbol9 v=dot h=&dotsize c=cxd95319;
symbol10 v=dot h=&dotsize c=cxedb120;
symbol11 v=dot h=&dotsize c=cx7e2f8e;
symbol12 v=dot h=&dotsize c=cx77ac30;
symbol13 v=dot h=&dotsize c=cx4dbeee;
symbol14 v=dot h=&dotsize c=cxa2142f;
symbol15 v=dot h=&dotsize c=cx0072bd;
symbol16 v=dot h=&dotsize c=cxd95319;
symbol17 v=dot h=&dotsize c=cxedb120;
symbol18 v=dot h=&dotsize c=cx7e2f8e;
symbol19 v=dot h=&dotsize c=cx77ac30;
symbol20 v=dot h=&dotsize c=cx4dbeee;
symbol21 v=dot h=&dotsize c=cxa2142f;
symbol22 v=dot h=&dotsize c=cx0072bd;
symbol23 v=dot h=&dotsize c=cxd95319;

*repeat the symbols until to 46, in case of drawing local manhattan plots with more than 23 groups;
*If there are more than 46 groups, the manhattan plots will be too busy!;
symbol24 v=dot h=&dotsize c=cx0072bd;
symbol25 v=dot h=&dotsize c=cxd95319;
symbol26 v=dot h=&dotsize c=cxedb120;
symbol27 v=dot h=&dotsize c=cx7e2f8e;
symbol28 v=dot h=&dotsize c=cx77ac30;
symbol29 v=dot h=&dotsize c=cx4dbeee;
symbol30 v=dot h=&dotsize c=cxa2142f;
symbol31 v=dot h=&dotsize c=cx0072bd;
symbol32 v=dot h=&dotsize c=cxd95319;
symbol33 v=dot h=&dotsize c=cxedb120;
symbol34 v=dot h=&dotsize c=cx7e2f8e;
symbol35 v=dot h=&dotsize c=cx77ac30;
symbol36 v=dot h=&dotsize c=cx4dbeee;
symbol37 v=dot h=&dotsize c=cxa2142f;
symbol38 v=dot h=&dotsize c=cx0072bd;
symbol39 v=dot h=&dotsize c=cxd95319;
symbol40 v=dot h=&dotsize c=cxedb120;
symbol41 v=dot h=&dotsize c=cx7e2f8e;
symbol42 v=dot h=&dotsize c=cx77ac30;
symbol43 v=dot h=&dotsize c=cx4dbeee;
symbol44 v=dot h=&dotsize c=cxa2142f;
symbol45 v=dot h=&dotsize c=cx0072bd;
symbol46 v=dot h=&dotsize c=cxd95319;
%end;
%else %do;
 %local _ci_ ncls;
 %let ncls=%ntokens(&inputcolors);
 %do _ci_=1 %to &ncls;
    symbol&_ci_ v=dot h=&dotsize c=%scan(&inputcolors,&_ci_,%str( ));
 %end;
%end;
%mend;

/* END companion/research/advanced_figures/sources/definitions/Manhattan4DiffGWASs_png.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/Multgscatter_with_gene_exons.sas */
%macro Multgscatter_with_gene_exons(
bed_dsd=,/*This input dsd should contain association signals, but not 
for gene bed regions; the name of the var should not be misunderstood!
It should contain the arbitrary vars: chr, st, and end
If the bed_dsd is missing, the macro will use the min and max position from
the gene_exon_bed_dsd as a fake data set to draw track without the scatterplot;
The typical input format of bed_dsd would be:
chr st end grp num_scattergrp num_lattice_scattergrp
the var grp should be character;
*/
Variant_Length_Var=,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=st-0.5*&Variant_Length_Var and end=st-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
For SNVs, please assign missing value . to them;
*/
yval_var=,
scatter_grp_var=,
lattice_subgrp_var=,
gene_exon_bed_dsd=,
/*
This input dsd is for exonic bed regions, which should contains the following vars:
chr, st, end, and grp, and these varnames are fixed and used by the internal macro!
Make sure there is only one unique chr included in the gene_exon_bed_dsd when the 1st data set bed_dsd is missing!
The typical input format of gene_exon_bed_dsd would be:
chr st end grp num_scattergrp
grp would be character, such as gene or exon
char_scattergrp would be y-axis values for these genes and it corresponding exons;
*/
dist2st_and_end=50000,
design_width=1000,
design_height=200,
image_dpi=300,
barthickness=20,
dotsize=6,
grp_font_size=8,
/*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=circlefilled,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=%str(thickness=6 color=darkorange pattern=solid),/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
min_dist4genes_in_same_grps=0.3, 
/*this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 to plot ALL genes in the same line;
(2) give value between 0 and 1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track!*/
sc_labels_in_order= ,/*Provide scatter names matched with the numeric scatter_grp_var
Use _ to represent blank space in each name, and these _ will be changed back into blank space!*/

/*Note: More parameters included in the sub-macro Lattice_gscatter_over_bed_track 
can be modified to obtain better figures; please just find the sub-macro and
update the default setting for specific parameters to improve the final figure
*/
min_xaxis=,/*These two parameters will restrict the min and max position for xaxis*/
max_xaxis=,
yaxis_offset4min=0.05, /*provide 0-1 value or auto to offset the min of the yaxis*/
yaxis_offset4max=0.05, /*provide 0-1 value or auto or to offset the max of the yaxis*/
yoffset4max_drawmarkersontop=0.15,/*If draw scatterplot marker labels on the top of track, 
this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=3.5, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=%str(-log10%(P%)),/*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=%str(Z score),/*Visible title for the continuous colorbar when heatmap coloring is enabled*/
plot_title=,/*Optional visible title naming the plotted color metric.*/
xaxis_offset4min=0.02, /*provide 0-1 value or auto  to offset the min of the xaxis*/
xaxis_offset4max=0.02, /*provide 0-1 value or auto to offset the max of the xaxis*/
shift_text_yval=-0.2, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
fig_fmt=svg, /*output figure formats: svg, png, jpg, and others*/
pct4neg_y=2, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
adjval4header=-0.5, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/


makedotheatmap=1,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/
/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=%nrbquote(&lattice_subgrp_var),/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=darkgreen lightgreen deepskyblue,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=gold mediumred vipk,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=-8,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=8,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=cyan blue, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=%str(darkblue darkgreen darkred darkyellow 
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000
),
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

makeheatmapdotintooneline=0,/*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
var4label_scatterplot_dots=, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
var4mark_ld_scatterplot_dots=, /*Optional character variable containing '*' for LD-linked variants.*/
ld_marker_color=black,
ld_marker_legend_symbol=*,
ld_heatmap_var=,
ld_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F,
ld_heatmap_legend_title=%str(LD r2),
text_rotate_angle=90, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=,
font_size4textlabels=10,
label_headroom_frac=,
label_center_offset=,
auto_rotate2zero=0, /*supply value 1 when less than 3 text labels, it is good to automatically set the text_rotate_angel=0*/
pct2adj4dencluster=0.25, /*For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 5 top SNPs if track_width between 500 and 800, or 6 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!
and SNPs within a cluster are overlapped with each other or overlapped with elements from other SNP cluster, so it is feasible to 
avoid this issue by increasing the pct or reducing it, respectively*/
adj_spaces_among_top_snps=1 /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
);

%let missingscatterdsd=0;
%if %length(&bed_dsd)=0 %then %do;
 %put Going to use the ene_exon_bed_dsd to make fake scatterplot dsd;
 %let bed_dsd=fake_bed_dsd;
 proc sql;
 create table &bed_dsd as
 select *
 from &gene_exon_bed_dsd
 group by chr
 having st=min(st) or end=max(end);

 %let missingscatterdsd=1;
 *Also need to create these variables;
 %let yval_var=yval_var;
 %let lattice_subgrp_var=lattice_subgrp_var;
 
 data &bed_dsd;
 set &bed_dsd;
 *Assign yval_var with value 1, these values will be excluded latter by the sub-macro lattice_gscatter;
 *with the parameter NotDrawScatterPlot=&missingscatterdsd;
 &yval_var=1;
 *This variables should be the same types as that from gene_exon_bed_dsd;
 &scatter_grp_var=1;
 *This arbitary group var;
 grp="sc";
 *This variable should be numeric;
 &lattice_subgrp_var=1;
 run;
 *Only keep these common vars, other vars may be conficted with newly generated vars;
 data &gene_exon_bed_dsd;
 set &gene_exon_bed_dsd;
 keep chr st end grp;
 *Need to add the following var and asign negative value;
 *For gene and exon, this var need to be negative;
 &scatter_grp_var=-1;
 run;
%end;


/*proc print data=_last_(obs=10);run;*/

*Note: both the bed_dsd and gene_exon_bed_dsd should have char chromosomes;

/*
%chr_format_exchanger(
dsdin=_last_,
char2num=1,
chr_var=chr,
dsdout=a1);
*/

/*%chr_format_exchanger(
dsdin=x0,
char2num=0,
chr_var=chr,
dsdout=x1);
*/

/*data &gene_exon_bed_dsd;*/
/*set &gene_exon_bed_dsd;*/
/*&scatter_grp_var=-1;*/
/*run;*/

proc sql noprint;
select unique(chr) into: chrs separated by " "
from &bed_dsd;
%put These chromosomes are included in the bed dsd &bed_dsd: &chrs;

%let ci=1;

%do %while (%scan(&chrs,&ci) ne );
   %let _chr_=%scan(&chrs,&ci);
   %put running analysis for chromosome &_chr_;

   proc sql noprint;
   create table bed&_chr_ as
   select * 
   from &bed_dsd
   where chr="&_chr_";
   
   select min(st)-&dist2st_and_end,max(end)+&dist2st_and_end into: min_st,:max_end
   from bed&_chr_;

   create table exon&_chr_ as
   select chr,st,end,grp,
          -1 as &yval_var
   from &gene_exon_bed_dsd
   where chr="&_chr_" and (
         (st<=&min_xaxis and end>=&min_xaxis and end<=&max_xaxis ) or 
         (st>=&min_xaxis and end<=&max_xaxis) or 
         (end>=&max_xaxis and st<=&max_xaxis)
   ); 
*Remove duplicate gene positions, otherwise, these genes will be plotted multiple times in the gene track;
proc sort data=exon&_chr_ nodupkeys out=exon&_chr_ dupout=exondup&_chr_;
by _all_;
run; 

/*  
*Because the min_st and max_end is larger than then the actual disigned &min_xaxis and &max_xaxis;
*There will be more genes included in the output data set, leading to the wrong adjusted gene group number for drawing lattice scatter plot;  
   create table exon&_chr_ as
   select chr,st,end,grp,
          -1 as &yval_var
   from &gene_exon_bed_dsd
   where chr="&_chr_" and (
         (st<=&min_st and end>=&min_st and end<=&max_end ) or 
         (st>=&min_st and end<=&max_end) or 
         (end>=&max_end and st<=&max_end)
   );
 %put min_st is &min_st;
 %put max_end is &max_end;
 */
/*  %let noexon_dsd=0;*/
   %delete_empty_dsd(dsd_in=work.exon&_chr_);
   %if %eval(%sysfunc(exist(work.exon&_chr_))^=1) %then %do;
     %put Warning: no scatter data positions overlapped with exon regions, please enlarge the searching distance if the figure is not generated!;
/*       %abort 255;*/
/*	 %let noexon_dsd=1;*/
	 %put try to add a fake exon ranging from min_st to max_end;
	 data exon&_chr_;
	 set bed&_chr_(obs=1 keep=chr st end grp);
	 &yval_var=-1;
	 *Use this position just for indicating the fact that no genes are in the region;
	 st=&min_xaxis;
	 end=st+1;
	 grp="No gene in the region on &_chr_";
	 run;
   %end;
/*   %abort 255;*/
   /*Only if you want to draw bed track instead of scatter plot for these no gene data points, you can increase the ratio*/         
   %let dist4scatterplot=%sysevalf((&max_end-&min_st)*0.0001,integer);
   %local _effective_gene_dist_thrhd _gene_track_row_count _gene_track_row_retry_count _effective_pct4neg_y _effective_grp_font_size _effective_barthickness _total_gene_label_count _target_gene_track_rows;
   %let _effective_gene_dist_thrhd=&min_dist4genes_in_same_grps;
   %let _effective_pct4neg_y=&pct4neg_y;
   %let _effective_grp_font_size=&grp_font_size;
   %let _effective_barthickness=&barthickness;

   proc sql noprint;
   select count(distinct grp) into: _total_gene_label_count trimmed
   from exon&_chr_
   where not missing(grp);
   quit;
   %if %superq(_total_gene_label_count)= %then %let _total_gene_label_count=1;
   %let _target_gene_track_rows=%sysfunc(max(1,%sysfunc(min(24,%sysfunc(ceil(%sysevalf(&_total_gene_label_count/2.5)))))));

   *By asigning ngrp=-1, all gene tracks will be put under the refline y=0;
			*This will asign the negative value -1 to gene grps and draw them together on a single line;
   /*data exon&_chr_;set exon&_chr_;&yval_var=-1;run;*/

			*This will asign different negative values to gene grps and draw them separately;
			proc sort data=exon&_chr_;by grp;run;

/* 			data exon&_chr_; */
/* 			retain &yval_var 0; */
/* 			*Make sure to drop the &yval_var from the dsd, otherwise, the retain and if condition will not work; */
/* 			set exon&_chr_ (drop=&yval_var); */
/* 			*Draw all genes into separated lines, but these exons may be draw into single lines, too?; */
/* 			*if first.grp then &yval_var=&yval_var-1; */
/*             *Draw all genes in a single line; */
/*             if first.grp then &yval_var=-1; */
/* 			output; */
/* 			by grp; */
/* 			run; */
*Use a macro to asign yval_var by separating genes too close to each other;
*reg_type and focused_reg_type4grouping can be omitted if wanting to use the longest region as gene;
/*%abort 255;*/
   %adj_grpnum4close_gene_bed_regs(
   gene_bed_dsd=exon&_chr_,
   st_var=st,
   end_var=end,
   reg_type=,
   focused_reg_type4grouping=,
   gene_grp=grp,
   gene_dist_thrhd=&_effective_gene_dist_thrhd,
   dsdout=exon&_chr_,
   outnumgrp=_numgrp_
   );
   proc sql noprint;
   select max(_numgrp_) into: _gene_track_row_count trimmed
   from exon&_chr_;
   quit;
   %if %superq(_gene_track_row_count)= %then %let _gene_track_row_count=1;
   %let _gene_track_row_retry_count=0;
   %do %while (%sysevalf(%superq(_gene_track_row_count) < %superq(_target_gene_track_rows)) and %sysevalf(%superq(_effective_gene_dist_thrhd) >= 0) and &_gene_track_row_retry_count < 5);
      %let _gene_track_row_retry_count=%eval(&_gene_track_row_retry_count+1);
      %if %sysevalf(&_effective_gene_dist_thrhd>1) %then %do;
        %let _effective_gene_dist_thrhd=%sysfunc(int(%sysevalf(&_effective_gene_dist_thrhd*1.6)));
      %end;
      %else %do;
        %let _effective_gene_dist_thrhd=%sysevalf(%sysfunc(min(0.95,%sysevalf(&_effective_gene_dist_thrhd*1.5))));
      %end;
      %put NOTE: Dense gene labeling detected on &_chr_ with &_total_gene_label_count genes and &_gene_track_row_count rows, retry &_gene_track_row_retry_count with gene_dist_thrhd=&_effective_gene_dist_thrhd target_rows=&_target_gene_track_rows.;
      %adj_grpnum4close_gene_bed_regs(
      gene_bed_dsd=exon&_chr_,
      st_var=st,
      end_var=end,
      reg_type=,
      focused_reg_type4grouping=,
      gene_grp=grp,
      gene_dist_thrhd=&_effective_gene_dist_thrhd,
      dsdout=exon&_chr_,
      outnumgrp=_numgrp_
      );
      proc sql noprint;
      select max(_numgrp_) into: _gene_track_row_count trimmed
      from exon&_chr_;
      quit;
      %if %superq(_gene_track_row_count)= %then %let _gene_track_row_count=1;
   %end;
   %if %sysevalf(%superq(_gene_track_row_count) < %superq(_target_gene_track_rows)) %then %do;
      %put NOTE: Applying round-robin gene-row expansion on &_chr_ to reach target_rows=&_target_gene_track_rows while keeping all labels.;
      proc sql;
        create table exon&_chr_._row_seed as
        select grp,
               min(st) as grp_st,
               max(end) as grp_end,
               mean((st+end)/2) as grp_mid
        from exon&_chr_
        group by grp
        order by calculated grp_mid, calculated grp_st, grp
        ;
      quit;
      data exon&_chr_._row_seed;
        set exon&_chr_._row_seed;
        _target_numgrp_=mod(_n_-1,&_target_gene_track_rows)+1;
      run;
      proc sort data=exon&_chr_;
        by grp st end;
      run;
      proc sort data=exon&_chr_._row_seed;
        by grp;
      run;
      data exon&_chr_;
        merge exon&_chr_(in=a) exon&_chr_._row_seed(keep=grp _target_numgrp_);
        by grp;
        if a;
        _numgrp_=_target_numgrp_;
        drop _target_numgrp_;
      run;
      %let _gene_track_row_count=&_target_gene_track_rows;
   %end;
   %if %sysevalf(%superq(_gene_track_row_count) > 24) %then %do;
      %let _effective_pct4neg_y=%sysfunc(max(&_effective_pct4neg_y,7.0));
      %let _effective_grp_font_size=%sysfunc(max(&_effective_grp_font_size,6));
      %let _effective_barthickness=%sysfunc(max(3,%sysevalf(&_effective_barthickness-5)));
   %end;
   %else %if %sysevalf(%superq(_gene_track_row_count) > 18) %then %do;
      %let _effective_pct4neg_y=%sysfunc(max(&_effective_pct4neg_y,5.8));
      %let _effective_grp_font_size=%sysfunc(max(&_effective_grp_font_size,6));
      %let _effective_barthickness=%sysfunc(max(4,%sysevalf(&_effective_barthickness-4)));
   %end;
   %else %if %sysevalf(%superq(_gene_track_row_count) > 12) %then %do;
      %let _effective_pct4neg_y=%sysfunc(max(&_effective_pct4neg_y,4.6));
      %let _effective_grp_font_size=%sysfunc(max(&_effective_grp_font_size,6));
      %let _effective_barthickness=%sysfunc(max(4,%sysevalf(&_effective_barthickness-3)));
   %end;
   %else %if %sysevalf(%superq(_gene_track_row_count) > 8) %then %do;
      %let _effective_pct4neg_y=%sysfunc(max(&_effective_pct4neg_y,3.6));
      %let _effective_grp_font_size=%sysfunc(max(&_effective_grp_font_size,7));
      %let _effective_barthickness=%sysfunc(max(5,%sysevalf(&_effective_barthickness-3)));
   %end;
   %put NOTE: Final gene-track layout on &_chr_: genes=&_total_gene_label_count rows=&_gene_track_row_count target_rows=&_target_gene_track_rows gene_dist_thrhd=&_effective_gene_dist_thrhd pct4neg_y=&_effective_pct4neg_y grp_font_size=&_effective_grp_font_size barthickness=&_effective_barthickness.;
/*%abort 255;*/
   *Asign negative value to &yval_var;
   *Note: the above macro can not output the var outnumgrp with the same name of &yval_var in the table exon&_chr_;
   data exon&_chr_(drop=_numgrp_);
   set exon&_chr_;
   &yval_var=-1*_numgrp_;
   run;
			
   data _x1_;
   set bed&_chr_ exon&_chr_;
			*enlarge the dist between st and end, which will make the square visible in scatter plot; 
/*			st=st-&dist4scatterplot;*/
			if st<0 then st=0;
/*			end=end+&dist4scatterplot;*/
   run;

		

			*Fix a bug here;
			*Need to asign -1 for all groups of &yval_var;
			*such as &yval_var1,&yval_var2, and so on;
			*If not fix the bug, these missing groups will be ploted at the bottern of each subplot;
		 data _x1_;
			set _x1_;
			*No need to process these data when missingscatterdsd is true;
			%if &missingscatterdsd=0 %then %do;
			array Y{*} &yval_var.:;
			do yi=1 to dim(Y);
			   if Y{yi}=. then Y{yi}=-1;
			end;
			drop yi;
			%end;
			if &scatter_grp_var=. then &scatter_grp_var=-1;
			run;

	
   /*proc print;run;*/
   *options nonotes;
   *old macro %bed_region_plot_by_grp, which is slow!;
   *Use the new macro by plotting scatter plot;
   *There are many more parameters with default settings are not;
   *listed out for the following macro, and it is easy to the change;
   *them for better visualization in the final figure;
    %let yaxislabel=&scatter_yaxis_label;
    *remove yaxis label when setting of NotDrawScatterPlot is true;
    %if &missingscatterdsd=1 %then %let yaxislabel=;
/*	%abort 255;*/
    %Lattice_gscatter_over_bed_track(
    bed_dsd=_x1_,
    chr_var=chr,
    st_var=st,
    end_var=end,
    Variant_Length_Var=&Variant_Length_Var,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=st-0.5*&Variant_Length_Var and end=st-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!*/
    grp_var=grp,
    scatter_grp_var=&scatter_grp_var,
    lattice_subgrp_var=&lattice_subgrp_var,
    yval_var=&yval_var,
    yaxis_label=&yaxislabel,
    linethickness=&_effective_barthickness,
    track_width=&design_width,
    track_height=&design_height,
    image_dpi=&image_dpi,
    dist2st_and_end=&dist2st_and_end,
    dotsize=&dotsize,
    grp_font_size=&_effective_grp_font_size,
	/*Important parameters for drawing SNVs and CNVs together*/
    scattermarker_symbol=&scattermarker_symbol,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
   highlow_line_cmd=&highlow_line_cmd,/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
    ordered_sc_grpnames=&sc_labels_in_order,
    NotDrawScatterplot=&missingscatterdsd,
    xaxis_viewmin=&min_xaxis,/*arbitrary xaxis min value to show the figure, and it requires to work with thresholdmin=0*/
    xaxis_viewmax=&max_xaxis,/*arbitrary xaxis max vale to show the figure, and it requires to go along with thresholdmax=0*/
    yaxis_offset4min=&yaxis_offset4min, /*provide 0-1 value or auto to offset the min of the yaxis*/
    yaxis_offset4max=&yaxis_offset4max, /*provide 0-1 value or auto or to offset the max of the yaxis*/
    yoffset4max_drawmarkersontop=&yoffset4max_drawmarkersontop,/*If draw scatterplot marker labels on the top of track, 
    this fixed value will be used instead of yaxis_offset4max!*/
      Yoffset4textlabels=&Yoffset4textlabels, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
      heatmap_legend_title=&heatmap_legend_title, /*Visible title for the continuous colorbar when heatmap coloring is enabled*/
      plot_title=&plot_title,
      xaxis_offset4min=&xaxis_offset4min, /*provide 0-1 value or auto  to offset the min of the xaxis*/
    xaxis_offset4max=&xaxis_offset4max, /*provide 0-1 value or auto to offset the max of the xaxis*/

  shift_text_yval=&shift_text_yval, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
  fig_fmt=&fig_fmt, /*output figure formats: svg, png, jpg, and others*/
  pct4neg_y=&_effective_pct4neg_y, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
  adjval4header=&adjval4header, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/

 makedotheatmap=&makedotheatmap,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/
/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=&heatmap_var,/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=&heatmap_Neg_rangealtcolormodel,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=&heatmap_Pos_rangealtcolormodel,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=&heatmap_min_neg_val,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=&heatmap_max_pos_val,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=&color_resp_var,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=&fixedcols4tracksunderscatter, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=&color_resp_grpdsd,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=&dataContrastCols,
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

 makeheatmapdotintooneline=&makeheatmapdotintooneline, /*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
 var4label_scatterplot_dots=&var4label_scatterplot_dots, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/ 
 var4mark_ld_scatterplot_dots=&var4mark_ld_scatterplot_dots,
 ld_marker_color=&ld_marker_color,
 ld_marker_legend_symbol=&ld_marker_legend_symbol,
 ld_heatmap_var=&ld_heatmap_var,
 ld_heatmap_colormodel=&ld_heatmap_colormodel,
 ld_heatmap_legend_title=&ld_heatmap_legend_title,
text_rotate_angle=&text_rotate_angle, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=&label_position_overrides,
font_size4textlabels=&font_size4textlabels,
label_headroom_frac=&label_headroom_frac,
label_center_offset=&label_center_offset,
auto_rotate2zero=&auto_rotate2zero, /*supply value 1 when less than 3 text labels, it is good to automatically set the text_rotate_angel=0*/
pct2adj4dencluster=&pct2adj4dencluster,
adj_spaces_among_top_snps=&adj_spaces_among_top_snps /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
    );
  
   *options notes;
%let ci=%eval(&ci+1);
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/Multgscatter_with_gene_exons.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/OpenSVG_Printer.sas */
%macro OpenSVG_Printer(
filename=mysvgfilename,
svgfileref=out,
other_paras4ods_graphics=%str( ),
outdir=,/*output svg to the dir; if empty, it will save it 
into the dir %sysfunc(pathname(HOME));*/
);

*In Windows, due to sysfunc(pathname(HOME)) only works in Linux;
*the SVG will be failed to be written into the SAS installation dir;
*To address the issue, change the dir into working dir;
%if &sysscp=WIN %then %do;
data _null_;
rx=dlgcdir("%sysfunc(getoption(work))");
run;
%end;
%else %if %length(&outdir)=0 %then %do;
data _null_;
rx=dlgcdir("%sysfunc(pathname(HOME))");
run;
%end;

*Check whether the svg exist;
*add appendix to it to not overwrite previous svg;
%let fi=1;
%let oldname=&filename;
%do %while (%FileOrDirExist(%sysfunc(pathname(HOME))/&filename..svg)=1);
  %put rename your svg output filename as:;
  %let filename=&oldname._&fi;
  %put &filename;
  %let fi=%eval(&fi+1);
%end;

options printerpath=(svg &svgfileref) nobyline;
filename out "&filename..svg";
ods listing close;
ods printer;
ods graphics on/outputfmt=svg
&other_paras4ods_graphics;

%if &sysscp=WIN %then %do;
data _null_;
rx=dlgcdir("%sysfunc(getoption(work))");
run;
%end;
%else %do;
data _null_;
rx=dlgcdir("%sysfunc(pathname(HOME))");
run;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/OpenSVG_Printer.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/QQplot.sas */
%macro QQplot(dsdin,P_var);
proc sql noprint;
select count(*) into: tot
from &dsdin;

data &dsdin;
set &dsdin;
where &P_var>0;

*sort and exclude these missing P values;
proc sort data=&dsdin;
by &P_var;
run;

data dataout;
set &dsdin;
retain x_;
gap=1/&tot;
ini=gap/2;
if _n_=1 then x_=ini;
else x_=x_+gap;
x=-log10(x_);
y=-log10(&P_var);
run;


proc sql noprint;
select ceil(max(y)) into: max_y
from dataout;

*Adjust the tick number when the &max_y>10;
%let step=1;
%if &max_y>=20 %then %do;
  %let step=5;
  *Update the max_y can be divided by 5;
  %let max_y=%sysevalf(%sysevalf(&max_y/5,ceil)*5);
%end;

/*make sure to put reset here*/
/*otherwise symbol2 will not work*/
goptions reset=global hsize=15cm vsize=15cm;
symbol1 interpol=none value=dot color=maroon;
symbol2 interpol=rl value=none color=black;
%let fontsize=3;
axis1 label=(f='arial' h=&fontsize 'Expected -log10(P)' justify=c)
      order=(0 to &max_y by &step) value=(f='arial' h=&fontsize);
axis2 label=(a=90 f='arial' h=&fontsize 'Observed -log10(P)')
      order=(0 to &max_y by &step) value=(f='arial' h=&fontsize);
proc gplot data=dataout;
plot y*x x*x/overlay 
           haxis=axis1
           vaxis=axis2
           noframe;
run;

*Also make a QQ plot with x- and y-axis with the same scale and maximum value of 8;
goptions reset=global hsize=15cm vsize=15cm;
symbol1 interpol=none value=dot color=maroon;
symbol2 interpol=rl value=none color=black;
%let fontsize=3;
axis1 label=(f='arial' h=&fontsize 'Expected -log10(P)' justify=c)
      order=(0 to 8 by 1) value=(f='arial' h=&fontsize);
axis2 label=(a=90 f='arial' h=&fontsize 'Observed -log10(P)')
      order=(0 to 8 by 1) value=(f='arial' h=&fontsize);
proc gplot data=dataout;
plot y*x x*x/overlay 
           haxis=axis1
           vaxis=axis2
           noframe;
run;

%mend;

/* END companion/research/advanced_figures/sources/definitions/QQplot.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/QueryLD_SNPs_at_Haploreg4.sas */
%macro QueryLD_SNPs_at_Haploreg4(
  snp=rs2564978,
  LDpop=EUR,
  ldThresh=0.7,
  outdsd=LD_dsd
);
%local query_str _http_status _has_rsid _has_r2 _n_rows _out_lib _out_mem _response_bytes _response_records
       _cache_min _cache_action _cache_self_n;
%global HAPLOREG_LD_HTTP_STATUS HAPLOREG_LD_QUERY_OK HAPLOREG_LD_QUERY_SOURCE
        HAPLOREG_LD_CACHE_DSD HAPLOREG_LD_CACHE_MIN_R2 HAPLOREG_LD_CACHE_MISS_ACTION;
%let HAPLOREG_LD_HTTP_STATUS=;
%let HAPLOREG_LD_QUERY_OK=0;
%let HAPLOREG_LD_QUERY_SOURCE=NONE;
%if %sysfunc(countw(%superq(outdsd),.))>1 %then %do;
  %let _out_lib=%scan(%superq(outdsd),1,.);
  %let _out_mem=%scan(%superq(outdsd),-1,.);
%end;
%else %do;
  %let _out_lib=WORK;
  %let _out_mem=&outdsd;
%end;

/*
Optional local cache. The cache is a long table with QUERY_SNP, PROXY_SNP,
LD_POPULATION, PROXY_R2, and CACHE_MIN_R2. It can be produced by
extract_haploreg_ld_for_candidates.pl from the official downloadable archives.
Archive data are available only from r2=0.2 upward; a cache is never used for a
lower requested cutoff. A cache miss falls back to the web query by default.
*/
%let _cache_action=%upcase(%sysfunc(strip(%superq(HAPLOREG_LD_CACHE_MISS_ACTION))));
%if %sysevalf(%superq(_cache_action)=,boolean) %then %let _cache_action=WEB;
%let _cache_min=%sysfunc(inputn(%superq(HAPLOREG_LD_CACHE_MIN_R2),best32.));
%if %sysevalf(%superq(_cache_min)=,boolean) %then %let _cache_min=0.2;

%if not %sysevalf(%superq(HAPLOREG_LD_CACHE_DSD)=,boolean)
    and %sysfunc(exist(%superq(HAPLOREG_LD_CACHE_DSD))) %then %do;
  %if %sysevalf(&ldThresh >= &_cache_min) %then %do;
    data &outdsd;
      length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
      set &HAPLOREG_LD_CACHE_DSD;
      where query_snp=upcase("&snp")
        and ld_population=upcase("&LDpop")
        and proxy_r2 >= &ldThresh;
      query_snp_rsid="&snp";
      rsID=strip(proxy_snp);
      r2=proxy_r2;
      chr='';
      pos_hg38=.;
      keep query_snp_rsid rsID chr pos_hg38 r2;
    run;
    proc sql noprint;
      select count(*) into :_cache_self_n trimmed
      from &outdsd
      where upcase(strip(rsID))=upcase("&snp");
    quit;
    %if %sysevalf(%superq(_cache_self_n)=,boolean) %then %let _cache_self_n=0;
    %if &_cache_self_n>0 %then %do;
      %let HAPLOREG_LD_HTTP_STATUS=LOCAL_CACHE;
      %let HAPLOREG_LD_QUERY_OK=1;
      %let HAPLOREG_LD_QUERY_SOURCE=LOCAL_CACHE;
      %put NOTE: HaploReg LD cache hit snp=&snp population=&LDpop threshold=&ldThresh cache=&HAPLOREG_LD_CACHE_DSD.;
      %return;
    %end;
    %put WARNING: HaploReg LD cache miss for &snp population=&LDpop.;
    %if &_cache_action ne WEB %then %do;
      %let HAPLOREG_LD_HTTP_STATUS=CACHE_MISS;
      %let HAPLOREG_LD_QUERY_SOURCE=LOCAL_CACHE_MISS;
      %return;
    %end;
  %end;
  %else %put WARNING: Ignoring HaploReg LD cache because requested r2=&ldThresh is below cache minimum r2=&_cache_min.;
%end;

%let query_str=%nrstr(&query=)&snp%nrstr(&ldThresh=)&ldThresh%nrstr(&ldPop=)&LDpop%nrstr(&output=text&submit=submit);
%let HAPLOREG_LD_QUERY_SOURCE=WEB;

filename hap temp lrecl=1000000000;
proc http
  url="https://pubs.broadinstitute.org/mammals/haploreg/haploreg.php/post"
  method="POST"
  in="&query_str"
  out=hap
  ct='application/x-www-form-urlencoded';
run;

%let _http_status=&SYS_PROCHTTP_STATUS_CODE;
%let HAPLOREG_LD_HTTP_STATUS=&_http_status;

%if %sysevalf(%superq(_http_status)=,boolean)
    or %sysevalf(&_http_status < 200)
    or %sysevalf(&_http_status >= 400) %then %do;
  %put WARNING: HaploReg LD query failed for &snp population=&LDpop HTTP=&_http_status.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  filename hap clear;
  %return;
%end;

%let _response_bytes=0;
data _null_;
  length _size_text $64;
  _fid=fopen('hap');
  if _fid>0 then do;
    _size_text=finfo(_fid,'File Size (bytes)');
    call symputx('_response_bytes',input(compress(_size_text,,'kd'),best32.),'L');
    _rc=fclose(_fid);
  end;
run;
%if %sysevalf(%superq(_response_bytes)=,boolean) %then %let _response_bytes=0;
%if %sysevalf(&_response_bytes <= 0) %then %do;
  %put WARNING: HaploReg returned an empty response for &snp population=&LDpop.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  filename hap clear;
  %return;
%end;

/*
PROC IMPORT writes a fatal-looking ERROR when HaploReg returns only a blank
line or a header without data.  Count nonblank records first so an expected
"no LD response" is represented by an empty data set and audit status instead
of poisoning an otherwise successful SAS ODA job log.
*/
%let _response_records=0;
data _null_;
  infile hap lrecl=32767 truncover end=_eof;
  input;
  if not missing(_infile_) then _n_nonblank+1;
  if _eof then call symputx('_response_records',_n_nonblank,'L');
run;
%if %sysevalf(%superq(_response_records)=,boolean) %then %let _response_records=0;
%if %sysevalf(&_response_records < 2) %then %do;
  %put WARNING: HaploReg returned no tabular LD rows for &snp population=&LDpop.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  filename hap clear;
  %return;
%end;

proc import datafile=hap dbms=tab out=&outdsd replace;
  getnames=yes;
  guessingrows=max;
run;
filename hap clear;

%if not %sysfunc(exist(&outdsd)) %then %do;
  %put WARNING: HaploReg returned no importable table for &snp population=&LDpop.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  %return;
%end;

proc sql noprint;
  select sum(upcase(name)='RSID'),
         sum(upcase(name)='R2')
    into :_has_rsid trimmed,
         :_has_r2 trimmed
  from dictionary.columns
  where libname=upcase("&_out_lib")
    and memname=upcase("&_out_mem")
  ;
quit;

%if %sysevalf(%superq(_has_rsid)=,boolean) %then %let _has_rsid=0;
%if %sysevalf(%superq(_has_r2)=,boolean) %then %let _has_r2=0;

%if &_has_rsid=0 or &_has_r2=0 %then %do;
  %put WARNING: HaploReg response for &snp population=&LDpop lacks rsID or r2 columns.;
  data &outdsd;
    length query_snp_rsid rsID $128 chr $16 pos_hg38 r2 8;
    stop;
  run;
  %return;
%end;

data &outdsd;
  length query_snp_rsid $128;
  set &outdsd(drop=query_snp_rsid);
  query_snp_rsid="&snp";
run;

proc sql noprint;
  select count(*) into :_n_rows trimmed
  from &outdsd
  where upcase(strip(rsID))=upcase("&snp")
  ;
quit;
%if %sysevalf(%superq(_n_rows)=,boolean) %then %let _n_rows=0;
%if %sysevalf(&_n_rows > 0) %then %let HAPLOREG_LD_QUERY_OK=1;

%put NOTE: HaploReg LD query snp=&snp population=&LDpop threshold=&ldThresh HTTP=&_http_status query_ok=&HAPLOREG_LD_QUERY_OK.;
%mend;

/* END companion/research/advanced_figures/sources/definitions/QueryLD_SNPs_at_Haploreg4.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/RandBetween.sas */
%macro RandBetween(min, max);
%local min max rnd _unif_num_ _rnd_;
%let _unif_num_=%sysfunc(ranuni(0));
%let _rnd_=%sysevalf((1+&max-&min)*&_unif_num_);
%let rnd=%sysfunc(floor(&_rnd_));
&rnd
%mend;

/* END companion/research/advanced_figures/sources/definitions/RandBetween.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/Rename_Del_Rgx4All_Vars.sas */
%macro Rename_Del_Rgx4All_Vars(indsd,Rgx);
%let dsd_name=%scan(&indsd,-1,'.');
%let dsd_lib=%scan(&indsd,-2,'.');
proc sql noprint;
create table temp as 
select name,label,format
  from dictionary.columns
  where libname=upper("&dsd_lib") and
        memname=upper("&dsd_name") and 
		memtype="DATA";
data temp;
set temp;
newname=prxchange("s/&Rgx//",-1,name);
run;

proc sql noprint;
   select count(*) into :n from temp
   where prxmatch("/&Rgx/",name);

%if &n>0 %then %do;
proc sql noprint;
   select cat('rename ',strip(name),
              '= ',strip(newname),';')
      into :l1 - %sysfunc(compress(:l&n))
      from temp
   where prxmatch("/&Rgx/",name);
quit;

proc datasets lib=&dsd_lib nolist;
modify &dsd_name;
   %do i = 1 %to &n; 
     &&l&i 
   %end;
run;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/Rename_Del_Rgx4All_Vars.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/SNP_Local_Manhattan_With_GTF.sas */
%macro SNP_Local_Manhattan_With_GTF(
/*Note: this macro can draw CNVs and SNVs together. Please ensure the macro variable
Variant_Length_Var is not empty, which contains distance of these CNVs (>1), with non-CNVs
assigned with missing value, and the middle positions of these CNVs is required to be 
combined with that of SNVs and gene tracks!

Tip 1: when there gene labels are cluttered within the gene track, it is feasible to 
resolve the issue by increasing the values for either variable pct4neg_y or dist2sep_genes or both!
such as pct4neg_y and dist2sep_genes=1000000; alternatively, it also possible to address the problem
by increase the width of figure, such as assigning larger value to the macro variable track_width=800.

  Tip 2: the figure width and height should ideally set around 500 and no less then 300 or greater than
1000, as large figures are not good for publication purpose! 

  Tip 3: For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 4 top SNPs if track_width between 500 and 800, or 5 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!

 Tip 4: dist_pct_to_cluster_pos and pct2adj4dencluste (0.0001 to ~) can affect the top SNP labels positions when there are <= 3 or 4, or 5 SNP labels, as the its value
dist_pct_to_cluster_pos will be internally replaced as 0.5/total number of top SNPs, and pct2adj4dencluste will be changed differently
when make_even_pos=1, the macro will multiple the amplification_fc with 10*pct2adj4dencluster to further enlarge the even distance among positions; 
while if make_even_pos=0, it is useful when elements within a cluster is overlapped with each other or overlapped with elements from other cluster, 
so it is also feasible to avoid this issue by increasing or reducing the pct.

 Tip 5: In default, the scatterplot will use the transformed values of all variables inclued in the macro variable
ZscoreVars into a variable for the lattice_subgrp_var to color dots differently across different scatter groups; User can supply
an independent variable represented by the macro variable color_resp_var to color scatter plot dots but different scattergroups
will be applied in a union style! 
*/

/*
As this macro use other sub-macros, it is not uncommon that some global macro
vars would be in the same name, such as macro vars chr and i, thus, to avoid of crash, 
chr_var is used instead of macro var chr in this macro;*/
/*
Important: there are many other parameters of the sub-macro Lattice_gscatter_over_bed_track,
which can be modified by changing the default values for them to improve the quality of final produced figure!
*/

focus_on_transcript=0,/*This will generate a subset exon GTF data set by 
replacing gene variable with ensembl transcript variable and removing rows 
with the type of "gene" and update transcript as "gene" to enable the macro
to work on these transcripts instead of genes*/
gwas_dsd=,
chr_var=chr,
AssocPVars=pval1 pval2,
SNP_IDs=rs370604612 rs2070788 9:5114773,
/*if providing chr:pos or chr:st:end, it will query by pos;
Please also enlarge the dist2snp to extract the whole gene body and its exons,
although the final plots will be only restricted by the input start and end positions!*/
dist2snp=2000000,
chromosome_lengths=,/*Comma-separated lengths for chromosomes 1-22, X, Y in the GWAS build.*/
/*assign value in bp, and the final figure will be add extend this distance for both start and end positions*/
SNP_Var=snp,
Pos_Var=pos,
Variant_Length_Var=,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=&Pos_Var-0.5*&Variant_Length_Var and end=&Pos_Var-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
*/
gtf_dsd=FM.GTF_HG19,
ZscoreVars=zscore1 zscore2,/*Can be beta1 beat2 or other numberic vars indicating assoc or other +/- directions,
the values of which can be used to color scatter plots of association signals specifically for its corresponding scatter
plot group membership for the following gwas labels. Please ensure makedotheatmap=1 and the input zscoreVars 
are in the same type of variable that can be used properly along with the heatmap feature*/ 
gwas_labels_in_order=gwas1 gwas2,/*If providing _ for labeling each GWAS, 
the _ will be replaced with empty string, which is useful when wanting to remove gwas label 
if only one scatterplot or the label for a gwas containing spaces;
The list will be used to label scatterplots 
by the sub-macro map_grp_assoc2gene4covidsexgwas*/
design_width=500,/*Best width for publication, and usually used width rangs from 400 to 800*/ 
design_height=500,/*Best height for publication, and usally used height rangs from 400 to 800*/
image_dpi=300,/*Raster output DPI; the SAS ODA wrapper uses 150 to limit Java memory.*/
barthickness=10, /*gene track bar thinkness*/
dotsize=6,/*scatter data point size for the following macro variable scattermarker_symbol*/
grp_font_size=8,/*font size for gene labels in the bottom gene track*/

/*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=circlefilled,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=%str(thickness=6 color=darkorange pattern=solid),/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/

dist2sep_genes=100000,/*Distance to separate close genes into different rows in the gene track; provide negative value or 0
to have all genes in a single row in the final gene track
this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 or negative value to plot ALL genes in the same line;
(2) give value >0 and <1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track!*/
where_cndtn_for_gwasdsd=%str(), /*where condition to filter input gwas_dsd*/

shift_text_yval=0.1, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
fig_fmt=png, /*output figure formats: svg, png, jpg, and others*/
pct4neg_y=2, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
adjval4header=-0.2, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/
makedotheatmap=1,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot
Note: the macro is updated to use heatmap to illustrate positve and negative values
of scatter plot represented by the variable ZscoreVars in the sub macros
map_grp_assoc2gene4covidsexgwas=>Multgscatter_with_gene_exons (HERE inside the 1st submacro) 
=>Lattice_gscatter_over_bed_track, and you can see the details by reading the 
parameters for  the 2nd sub macro used by the 1st sub mcro;
Set it as 0 to use binary mode to color the negative and postive values in scatter plot*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=AssocGrp,/*This variable is generated by transposing all ZscoreVars into a long format internally by the macro,
thus, do not change this macro variable, just update ZscoreVars accordingly; the macro uses this var to draw scatter plot in heatmap
with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=darkgreen lightgreen deepskyblue,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=gold mediumred vipk,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=-8,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=8,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/

color_resp_var=,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=cyan blue, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=%str(darkblue darkgreen darkred darkyellow 
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000
),
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

makeheatmapdotintooneline=0,/*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
var4label_scatterplot_dots= ,/*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
the variable should contain values of target SNPs and other non-targets are asigned with empty values;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
SNPs2label_scatterplot_dots=, /*Add multiple SNP rsids to label dots within or at the top of scatterplot
Note: if this parameter is provided, it will replace the parameter var4label_scatterplot_dots!
If there are too much space on the top for these SNP labels, please manually change default value of
the macro variable yoffset4max_drawmarkersontop included in the macro Lattice_gscatter_over_bed_track
 from 0.2 to a smaller value, such as 0.1;
*/
LD_SNPs2mark_scatterplot_dots=, /*Optional space-delimited LD-linked SNPs overlaid with the selected marker on every association track.*/
LD_marker_symbol=*, /*Marker text for LD-linked SNPs: *, +, x, o, s, ^, or d.*/
LD_marker_color=black, /*SAS color name or CXrrggbb value for LD-linked SNP markers.*/
LD_r2_values=, /*Space-delimited SNP:r2 pairs used by the optional LD heatmap overlay.*/
LD_r2_var=LD_R2, /*Numeric LD column uploaded with the GWAS plotting dataset.*/
LD_reference_snp=, /*Explicit LD reference SNP; falls back to the first labeled SNP when omitted.*/
LD_display_mode=none, /*none, markers, heatmap, or both. LD display is opt-in.*/
LD_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F, /*Retained for legacy marker-overlay mode.*/
LD_heatmap_legend_title=%str(LD r2),
text_rotate_angle=90, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=, /*Optional SNP=BP list computed before SAS to avoid label collisions.*/
font_size4textlabels=10, /*Actual text size used by the Perl label planner and SAS renderer.*/
label_headroom_frac=,
label_center_offset=,
auto_rotate2zero=1, /*supply value 1 when there are <=3 text labels and you want them kept horizontal in the top headroom*/
pct2adj4dencluster=2,/*Input value can be ranging from 0.0001 to 10 or even higher value!
For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 4 top SNPs if track_width between 500 and 800, or 5 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!
and SNPs within a cluster are overlapped with each other or overlapped with elements from other SNP cluster, so it is feasible to 
avoid this issue by increasing the pct or reducing it, respectively*/
yoffset4max_drawmarkersontop=0.25, /*If draw scatterplot marker labels on the top of track, 
 this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=3.5, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=%str(-log10%(P%)),/*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=%str(Z score),/*Visible title for the continuous colorbar when heatmap coloring is enabled*/
adj_spaces_among_top_snps=1,/*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
verbose=0 /*Not print any notes in SAS log*/
);

%local effective_ld_marker_var effective_ld_heatmap_var effective_heatmap_legend_title effective_plot_title _chrom_end_for_window;
%let effective_ld_marker_var=;
%let effective_ld_heatmap_var=;
%let effective_heatmap_legend_title=&heatmap_legend_title;
 
%*It is better to output these notes into the log for AI; 
%*However, too large number of notes will slow down the pipeline dramatically;
%*Thus, we will only print these notes when verbose=1;
%if &verbose=0 %then %do;
%put To prevent too many notes printed in the SAS log, we will enable options nonotes;
options nonotes;
%end;


*Note: the macro map_grp_assoc2gene4covidsexgwas requires the input dsd contain the var chr;
%if "&chr_var"^="chr" %then %do;
data &gwas_dsd;
set &gwas_dsd;
chr=&chr_var;
run;
%end;

*Add a compact star-overlay variable for LD-linked SNPs.;
%if %length(&LD_SNPs2mark_scatterplot_dots)>0 and
    (%upcase(&LD_display_mode)=MARKERS or %upcase(&LD_display_mode)=BOTH) %then %do;
 %let effective_ld_marker_var=_LD_SNP_MARK_;
 data &gwas_dsd;
 set &gwas_dsd;
 length _LD_SNP_MARK_ $8.;
 _LD_SNP_MARK_="";
 %do _li_=1 %to %ntokens(&LD_SNPs2mark_scatterplot_dots);
   if &SNP_Var="%scan(&LD_SNPs2mark_scatterplot_dots,&_li_,%str( ))" then _LD_SNP_MARK_="&LD_marker_symbol";
 %end;
 run;
%end;

*Add a numeric r2 overlay variable from the uploaded LD_R2 column.;
%if (%upcase(&LD_display_mode)=HEATMAP or %upcase(&LD_display_mode)=BOTH) %then %do;
 %let effective_ld_heatmap_var=_LD_R2_;
 data &gwas_dsd;
 set &gwas_dsd;
 _LD_R2_=&LD_r2_var;
 %let _ld_reference_snp_=&LD_reference_snp;
 %if %length(&_ld_reference_snp_)=0 %then %let _ld_reference_snp_=%scan(&SNPs2label_scatterplot_dots,1,%str( ));
 %if %length(&_ld_reference_snp_)=0 %then %let _ld_reference_snp_=%scan(&SNP_IDs,1,%str( ));
 if missing(_LD_R2_) and upcase(&SNP_Var)=upcase("&_ld_reference_snp_") then _LD_R2_=1;
 %if %length(%superq(LD_r2_values))>0 %then %do;
   %do _li_=1 %to %ntokens(&LD_r2_values);
     %let _ld_pair_=%scan(&LD_r2_values,&_li_,%str( ));
     if upcase(&SNP_Var)=upcase("%scan(&_ld_pair_,1,%str(:))") then
       if missing(_LD_R2_) then _LD_R2_=input("%scan(&_ld_pair_,2,%str(:))",best32.);
   %end;
 %end;
 run;
 %let effective_signed_r2=1;
 %let effective_ld_heatmap_var=;
%end;
%else %let effective_signed_r2=0;
%let effective_zscore_vars=&ZscoreVars;
%let effective_heatmap_min_neg_val=&heatmap_min_neg_val;
%let effective_heatmap_max_pos_val=&heatmap_max_pos_val;
%if &effective_signed_r2=1 %then %do;
  %let effective_zscore_vars=;
  data &gwas_dsd;
  set &gwas_dsd;
  %do _zi_=1 %to %sysfunc(countw(&ZscoreVars));
    _SIGNED_R2_&_zi_=0;
    if not missing(_LD_R2_) then do;
      if %scan(&ZscoreVars,&_zi_) < 0 then _SIGNED_R2_&_zi_=-_LD_R2_;
      else if %scan(&ZscoreVars,&_zi_) > 0 then _SIGNED_R2_&_zi_=_LD_R2_;
    end;
  %end;
  run;
  %do _zi_=1 %to %sysfunc(countw(&ZscoreVars));
    %let effective_zscore_vars=&effective_zscore_vars _SIGNED_R2_&_zi_;
  %end;
  %let effective_heatmap_min_neg_val=-1;
  %let effective_heatmap_max_pos_val=1;
  %let effective_heatmap_legend_title=&LD_heatmap_legend_title;
%end;

*Add labels for target SNPs if they exist;
%if %length(&SNPs2label_scatterplot_dots)>0 %then %do;
 %let var4label_scatterplot_dots=_Target_SNP_;
data &gwas_dsd;
set &gwas_dsd;
length _Target_SNP_ $25.;
 _Target_SNP_="";
 %do _si_=1 %to %ntokens(&SNPs2label_scatterplot_dots);
    if &SNP_Var="%scan(&SNPs2label_scatterplot_dots,&_si_,%str( ))" then _Target_SNP_=&SNP_Var;
 %end;
run;
%end;

%do snpi=1 %to %ntokens(&SNP_IDs);
  *query SNP using the index snpi (do not use i that may interupt with other macro var i used other sub-macros!);
  %let qsnp=%scan(&SNP_IDs,&snpi,%str( ));
   %if %sysfunc(countc(&qsnp,%str(:)))=1 %then %do;
      *Manually add the start position as end position when the input is in the format of chrNum:Pos!;
      %let qsnp=%sysfunc(prxchange(s/^([^:]+):(\d+)/$1:$2:$2/,-1,&qsnp));
   %end;
  *determine whether input snp is a chrpos based markder;
  %if %sysfunc(prxmatch(/:/,&qsnp)) %then %do;
    %let qsnp=%sysfunc(prxchange(s/chr//i,-1,&qsnp));
    %let chrposquery=1;
    %let num_chr=%scan(&qsnp,1,%str(:));
    %let tgt_pos=%scan(&qsnp,2,%str(:));
    
    %let st_pos=%sysevalf(&tgt_pos-&dist2snp);
    %let end_pos=%sysevalf(&tgt_pos+&dist2snp);
    
    %if %sysfunc(countc(&qsnp,%str(:)))>1 %then %do;
     /*To keep the proc sql codes consistant for creating macros vars of minst and maxend;
     The position range need to be adjusted by dist2snp, because the proc sql command
     will substract and add the dist2snp to the st and end positions; By adding and substracting
     the dist2snp from st and end position, respectively, the final minst and maxend will
     be the same as the input st and end positions!*/
     %if &dist2snp<50000000 %then %do;
      %let st_pos=%sysevalf(%scan(&qsnp,2,%str(:)) - 50000000);
      %let end_pos=%sysevalf(%scan(&qsnp,3,%str(:)) + 50000000);
     %end;
     %else %do;
      %let st_pos=%sysevalf(%scan(&qsnp,2,%str(:)) - &dist2snp);
      %let end_pos=%sysevalf(%scan(&qsnp,3,%str(:)) + &dsdt2snp);    
     %end;
    %end;
    
  %end;
  %else %do;
    %let chrposquery=0;
    %if %sysfunc(prxmatch(/^rs/i,&qsnp)) and &dist2snp<10000 %then %do;
      %put Please be noted that your query SNP is rsid (&qsnp);
      %put It is necessary to expand the searching region > +/-10kb to get genes that cover the variant and specific genes!;
      %abort 255;
    %end;
  %end;
  
  title "Query SNP is &qsnp";
  proc sql noprint;
  select &chr_var,&SNP_Var,minst,maxend
  into: chr,:snp,:minst,:maxend
  from (
  select &chr_var,&SNP_Var,&Pos_Var-&dist2snp as minst,&Pos_Var+&dist2snp as maxend
  from &gwas_dsd
  %if &chrposquery=0 %then %do;
    where &SNP_Var="&qsnp"
  %end;
  %else %do;
    where &chr_var=&num_chr and 
    (&Pos_Var between 
      &st_pos and &end_pos
    )
  %end;
  );
  %if %sysfunc(countc(&qsnp,%str(:)))=2 %then %do;
     /*To keep the proc sql codes consistant for creating macros vars of minst and maxend;
     The position range need to be adjusted by dist2snp, because the proc sql command
     will substract and add the dist2snp to the st and end positions; By adding and substracting
     the dist2snp from st and end position, respectively, the final minst and maxend will
     be the same as the input st and end positions!*/
     %let chr=%scan(&qsnp,1,%str(:));
     %let minst=%sysevalf(%scan(&qsnp,2,%str(:))-&dist2snp);
     %let maxend=%sysevalf(%scan(&qsnp,3,%str(:))+&dist2snp);    
  %end;  
  
  %if %symexist(chr)=0 %then %do;
   %put no record for your query SNP &qsnp;
   %abort 255;
  %end;
  %if %length(%superq(chromosome_lengths))>0 %then %do;
    /* PROC SQL can pad numeric chromosome values in macro variables. Strip
       that padding before checking the chromosome and looking up its length. */
    %let _chrom_for_window=%sysfunc(strip(%superq(chr)));
    %if %sysfunc(prxmatch(/^(?:[1-9]|1[0-9]|2[0-4])$/,%superq(_chrom_for_window))) %then %do;
      %let _chrom_end_for_window=%scan(%superq(chromosome_lengths),&_chrom_for_window,%str(,));
      %if %sysevalf(&maxend>&_chrom_end_for_window) %then %do;
        %put NOTE: Clipping the local GTF x-axis for chromosome &_chrom_for_window from &maxend to its reference end &_chrom_end_for_window.;
        %let maxend=&_chrom_end_for_window;
      %end;
    %end;
  %end;
  %let force_lattice_xaxis_viewmin=&minst;
  %let force_lattice_xaxis_viewmax=&maxend;
  %if %sysevalf(&force_lattice_xaxis_viewmin<1) %then %let force_lattice_xaxis_viewmin=1;
  %put Your input three parameters for the SNP &qsnp are: chr=&chr minst=&minst maxend=&maxend;
  %put NOTE: The displayed x-axis for &qsnp will use the requested SNP-centered window [&force_lattice_xaxis_viewmin, &force_lattice_xaxis_viewmax].;

  /* SAS ODA already has the HTML5 plot destination open. The extra printer
     destination renders a second 300-DPI bitmap and can exhaust Java memory. */
  %if not %symexist(local_gtf_ods_html5) %then %do;
    %OpenSVG_Printer(
     filename=Local_SNP_Manhattanplot,
     svgfileref=out,
     other_paras4ods_graphics=%str(noborder)
     );
  %end;
/*  %abort 255;*/
  %if &effective_signed_r2=1 %then
    %let effective_plot_title=Signed LD r2 x sign(Z score): &qsnp;
  %else
    %let effective_plot_title=Z-score-colored local Manhattan: &qsnp;
  title "&effective_plot_title";
  %map_grp_assoc2gene4covidsexgwas(
focus_on_transcript=&focus_on_transcript,/*This will generate a subset exon GTF data set by 
replacing gene variable with ensembl transcript variable and removing rows 
with the type of "gene" and update transcript as "gene" to enable the macro
to work on these transcripts instead of genes*/ 
  gwas_dsd=&gwas_dsd, 
  gtf_dsd=&gtf_dsd, 
  chr=&chr, 
  min_st=&minst, 
  max_end=&maxend, 
  dist2genes=1000, 
  AssocPVars=&AssocPVars, 
  ZscoreVars=&effective_zscore_vars,
  gwas_labels_in_order=&gwas_labels_in_order,
  design_width=&design_width, 
  design_height=&design_height, 
  image_dpi=&image_dpi,
  barthickness=&barthickness, 
  dotsize=&dotsize, 
  grp_font_size=&grp_font_size,
  /*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=&scattermarker_symbol,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=&highlow_line_cmd,/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
  dist2sep_genes=&dist2sep_genes,
 /*this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 to plot ALL genes in the same line;
(2) give value between 0 and 1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track! */
  where_cndtn_for_gwasdsd=&where_cndtn_for_gwasdsd,
  gwas_pos_var=&Pos_Var,
  Variant_Length_Var=&Variant_Length_Var,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=&Pos_Var-0.5*&Variant_Length_Var and end=&Pos_Var-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
*/
  shift_text_yval=&shift_text_yval, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
  fig_fmt=&fig_fmt, /*output figure formats: svg, png, jpg, and others*/
 pct4neg_y=&pct4neg_y, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
  adjval4header=&adjval4header, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/
  makedotheatmap=&makedotheatmap,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=&heatmap_var,/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=&heatmap_Neg_rangealtcolormodel,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=&heatmap_Pos_rangealtcolormodel,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
  heatmap_min_neg_val=&effective_heatmap_min_neg_val,/*Minimum negative value for the heatmap_var when it is not empty;
change this to customize the minimum value for colorbar in heatmap*/
  heatmap_max_pos_val=&effective_heatmap_max_pos_val,/*Maximum postive value for the heatmap_var when it is not empty;
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=&color_resp_var,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=&fixedcols4tracksunderscatter, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=&color_resp_grpdsd,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=&dataContrastCols,
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

makeheatmapdotintooneline=&makeheatmapdotintooneline, /*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
var4label_scatterplot_dots=&var4label_scatterplot_dots, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
var4mark_ld_scatterplot_dots=&effective_ld_marker_var,
ld_marker_color=&LD_marker_color,
ld_marker_legend_symbol=&LD_marker_symbol,
ld_heatmap_var=&effective_ld_heatmap_var,
ld_heatmap_colormodel=&LD_heatmap_colormodel,
ld_heatmap_legend_title=&LD_heatmap_legend_title,
text_rotate_angle=&text_rotate_angle, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=&label_position_overrides,
font_size4textlabels=&font_size4textlabels,
label_headroom_frac=&label_headroom_frac,
label_center_offset=&label_center_offset,
auto_rotate2zero=&auto_rotate2zero, /*supply value 1 when there are <=3 text labels and you want them kept horizontal in the top headroom*/
pct2adj4dencluster=&pct2adj4dencluster,/*For SNP labels on the top, please try to use this parameter, which only works when there are less than or equal to 4 top SNPs
and SNPs within a cluster are overlapped with each other or overlapped with elements from other SNP cluster, so it is feasible to 
avoid this issue by increasing the pct or reducing it, respectively*/
yoffset4max_drawmarkersontop=&yoffset4max_drawmarkersontop, /*If draw scatterplot marker labels on the top of track, 
this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=&Yoffset4textlabels, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=&scatter_yaxis_label, /*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=&effective_heatmap_legend_title, /*Visible title for the continuous colorbar when heatmap coloring is enabled*/
plot_title=&effective_plot_title,
adj_spaces_among_top_snps=&adj_spaces_among_top_snps /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
  ); 
  %if not %symexist(local_gtf_ods_html5) %then %do;
    ods printer close;
    *Also need to close the fileref out generated by the macro;
    filename out clear;
    ods listing;
  %end;
  
  proc print data=&gwas_dsd;
  where &SNP_Var="&qsnp";
  run;
  
  *Need to delete previously generated dataset Final;
  proc datasets nolist;
/*   delete Final: _X1_ BEDCHR: Exon: X1 X2 TMP_: Single_DSD; */
  delete _X1_ BEDCHR: Exon: X1 X2 TMP_: Single_DSD;
  run;
  title;
  %let force_lattice_xaxis_viewmin=;
  %let force_lattice_xaxis_viewmax=;
  
%end;

*Reove target SNPs if they exist;
%if %length(&SNPs2label_scatterplot_dots)>0 %then %do;
data &gwas_dsd;
set &gwas_dsd;
drop _Target_SNP_;
run;
%end;

%if %length(&effective_ld_marker_var)>0 %then %do;
data &gwas_dsd;
set &gwas_dsd;
drop _LD_SNP_MARK_;
run;
%end;

%if %length(&effective_ld_heatmap_var)>0 %then %do;
data &gwas_dsd;
set &gwas_dsd;
drop _LD_R2_;
run;
%end;

%if &verbose=0 %then %do;
%put We will enable options notes;
options notes;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/SNP_Local_Manhattan_With_GTF.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/TotVarsInDsd.sas */
%macro TotVarsInDsd(/*This macro is able to count all, numeric, or character vars in a sas dataset*/
ds, /*This macro return total number of variables in a dsd*/
var_type=_all_ /*optional values including _all_, _numeric_, or _character_ 
for counting total number of all, numeric, or character vars*/
);
   
   %local dset dsid;
   %let dset=&ds;
   %let dsid = %sysfunc(open(&dset(keep=&var_type)));
   %if &dsid %then
      %do;
/*         %let nobs =%sysfunc(attrn(&dsid,NOBS));*/
         %let nvars=%sysfunc(attrn(&dsid,NVARS));
         %let rc = %sysfunc(close(&dsid));
          &nvars
      %end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/TotVarsInDsd.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/add_fake_pos_by_grp4nonnegvars.sas */
%macro add_fake_pos_by_grp4nonnegvars(
dsdin,
axis_var,/*No negative values are allowed for the target axis var*/
axis_grp,
new_fake_axis_var,
dsdout, /*Two new variables, tag var and tpos, can be used to draw a ref line to separe each group*/
axis_step=1, /*Add extra step to separate each group for the end value of axis_var*/
concise_output=0, /*Provide value 1 to only keep 3 vars and other vars included in the original input dsdin, 
including axis_var, axis_grp, and new_fake_axis_var, and others in the output dsdout*/
reset_1st_value_as_one=0 /*Default is not to reset the 1st value of each group as one;
Provide the value 1 to reset the 1st value of each group as 1 and other values to minus the 1st value in the input dsdin;
this would be helpful if the 1st position value of each group is too large to draw plot by group!*/ 
);

/*
%let dsdin=a;
%let axis_grp=g;
%let axis_var=y;
%let dsdout=b;
%let axis_step=1;
%let new_fake_axis_var=fy;
*/

*Test whether there are negative values in the &dsdin;
*the macro only works for values >= 0;
proc sql noprint;
select count(&axis_var) into: neg_var_tot
from &dsdin
where &axis_var<0;


%if &neg_var_tot>0 %then %do;
 %put the macro only works for positve values, and you dsd &dsdin contains &neg_var_tot number of negative values;
 %abort 255;
%end;


*Fix a bug when only one record in a group;
*make an extra copy for the records to make it has >1 records;
*This is because the script will not be able to update corrected;
*y axis labels if there is only one record for a group;

proc sql;
create table _single_ as 
select *
from &dsdin
group by &axis_grp
having count(&axis_grp)=1;

data &dsdin;
set &dsdin _single_;

proc sort data=&dsdin;
by &axis_grp &axis_var;
run;

data _dsdin_;
set &dsdin;
*Scale position value and make it larger by fold change;
*if &axis_var>0 then &axis_var=&fc2scale_pos_vals*&axis_var;
run;

*Reset the 1st axis_var as 1;
%if &reset_1st_value_as_one=1 %then %do;
%put Going to reset the 1st value of each group as one and other values will adjusted accordingly;
 proc sql;
create table _dsdin_ (drop=&axis_var) as
select a.*,
           a.&axis_var-min(a.&axis_var)+1 as _new_
from _dsdin_ as a
group by &axis_grp
order by &axis_grp,_new_;
data _dsdin_;
set _dsdin_;
rename _new_=&axis_var;
run;
%end;

data &dsdout;
retain tpos 0 step &axis_step grp_n 0 grpnum 0;
set _dsdin_;

n=_n_;
*add the var grp_n for sorting the values inside each group;
*which would be handy to handle all negative values by using the macro;
*the method is simply to change all negative values into positve, ane then;
*use this macro. Finally, flip the order of fake axis values by this var grp_n later;
*grp_n need to be put in the retain command;

if first.&axis_grp then do;
 fst_tag=1;
 grpnum=grpnum+1;
 grp_n=1;
 if n=1 then do;
   *important to make tpos as 0 when n=1;
   tpos=tpos;
   &new_fake_axis_var=&axis_var;
 end;
 else do;
   &new_fake_axis_var=&axis_var + tpos;
 end;
end;

if last.&axis_grp then do;
   grp_n=grp_n+1;
   tag=1;
   &new_fake_axis_var=tpos + &axis_var;
   if not first.&axis_grp then do;
      *only floor but not ceil can be used here;
      tpos=ceil(&axis_var) + tpos + step;
   end;
end;

if (not first.&axis_grp) and (not last.&axis_grp) then do;
 grp_n=grp_n+1;
 &new_fake_axis_var=&axis_var + tpos;
end;

by &axis_grp;

run;

*Also add a new var to indicate the middle axis value for each group;
data &dsdout;
retain mid_val 0;
set &dsdout;
if tag=1 then mid_val=tpos-0.5*(tpos-mid_val);
run;

data &dsdout;
set &dsdout;
*reassign missing value for mid_val whoes tag is not 1;
if tag=. then mid_val=.;
run;

*Make the last maximum value minus the step;
data &dsdout;
set &dsdout end=eoff;
if eoff then tpos=tpos-step;
run;
%if &concise_output=1 %then %do;
data &dsdout;
set &dsdout;
drop mid_val tpos step grp_n grpnum n fst_tag tag;
run;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/add_fake_pos_by_grp4nonnegvars.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/adj_grpnum4close_gene_bed_regs.sas */
%macro adj_grpnum4close_gene_bed_regs(
/*Note: the macro can only separate most of the bed regions
for better labeling bed regions, and usually the 1st track will be
good, with genes included in other tracks may not be well separated!*/
gene_bed_dsd=a,
st_var=st,
end_var=end,
reg_type=type,/*if empty, it will use the longest region as gene and 
               other shorter region from the same group as exons*/
focused_reg_type4grouping=gene,
gene_grp=grp,
gene_dist_thrhd=0.1,/*(1) give 0 or negative value to incluce all genes into a single group;
                      (2) given value in bp > 1 to separate genes by absolute distance in bp;
                      (3) if given value ranging from 0 to 1, it will use the pct of the whole region
                          to separate genes into different groups!
                          This option would be most useful to enable enough space for adding text on each
                          gene, as it will consider the length of gene as well as the distance between genes*/
dsdout=_gene_regions_,/*dsdout can be the same as gene_bed_dsd*/
outnumgrp=numgrp /*the var name for outnumgrp can not be same as other vars in gene_bed_dsd*/
);

%if "&gene_bed_dsd"="&dsdout" %then %do;
    %put Your input dsd name is the same as the output dsd name;
    %put we will temporarily change the &dsdout as: &dsdout._;
    %let old_dsdout=&dsdout;
    %let dsdout=&dsdout._;
%end;
%else %do;
    %let old_dsdout=&dsdout;
%end;

%if &reg_type ne %then %do;
  proc sort 
  data=&gene_bed_dsd(where=(&reg_type="&focused_reg_type4grouping"))
  out=&dsdout
  nodupkeys;
  by &st_var &end_var &gene_grp;
  run;
%end;
%else %do;
 data &dsdout;
 set &gene_bed_dsd;
 dist=&end_var - &st_var;
 run;
 proc sql;
 create table &dsdout(drop=dist) as 
 select &st_var,&end_var, &gene_grp, dist 
 from &dsdout
 group by &gene_grp
 having dist=max(dist);
%end;

*It is important to sort the start position again!;
*otherwise, the _grp_ number would not be the best!;
proc sort data=&dsdout;by &st_var;run;

proc sql noprint;
select left(put(count(&gene_grp),3.)) into: ngenes
from &dsdout;
run;

%if &gene_dist_thrhd > 0 %then %do;

 %if &gene_dist_thrhd<1 %then %do;
     proc sql noprint;
     select min(st),max(end) into: st_min,:end_max
     from &dsdout;
     %put Now we will use the relative distance based on the percent &gene_dist_thrhd of whole region;
     %put from &st_min to &end_max to separate genes into different groups!;
     %let gene_dist_thrhd=%sysevalf((&end_max-&st_min)*&gene_dist_thrhd);
 %end;
/*  data &dsdout(drop=_lag_end:);*/
 data &dsdout;
  retain _grp_ 1;
  set &dsdout;
  _lag_end_1=(lag(end) ^=.) and (abs(st-lag(end))<&gene_dist_thrhd or st-lag(end)<0);
  _lag_end_1= _lag_end_1 >0 or ((lag(st) ^=.) and (abs(st-lag(st))<&gene_dist_thrhd or st-lag(st)<0))>0;
  /*
  lag_end1=lag(end);
  */
  %do ni=2 %to &ngenes;
    /*
    lag_end2=lag2(end);
    lag_end3=lag3(end);
    */
    _lag_end_&ni=(lag&ni.(end) ^=.) and ((abs(st-lag&ni.(end))<&gene_dist_thrhd) or st-lag&ni.(end)<0);
    _lag_end_&ni=_lag_end_&ni>0 or ((lag&ni.(st) ^=.) and (abs(st-lag&ni.(st))<&gene_dist_thrhd or st-lag&ni.(st)<0))>0;
  %end;
  %if &ngenes>1 %then %do;
   *Add one to make it start from 1 for the 1st group;
    _grp_=sum(of _lag_end_1-_lag_end_&ngenes)+1;
  %end;
  run;
 %end;
 
%else %do;
 *Include all genes into one group;
 data &dsdout;
 set &dsdout;
 _grp_=1;
 run;
%end;
/*%abort 255;*/


*exclude records with the same consecutive _grp_;
data &dsdout(drop=_consect_grp_tag) 
     &dsdout._bad(drop=_consect_grp_tag);
set &dsdout;
_consect_grp_tag=lag(_grp_);
if (_consect_grp_tag=_grp_ and _grp_>1) then output &dsdout._bad;
else output &dsdout;
run;
/*for debugging*/
/* %abort 255; */

*make consective numeric groups for _grp_;
*The limitation of this part is that only element in the _grp_=1 can be separated well;
proc sort data=&dsdout;by _grp_ st end;
data &dsdout;
retain _cgrp_ 0;
set &dsdout;
if first._grp_ then _cgrp_=_cgrp_+1;
by _grp_;
run;

*Combine the grps, such as n+1 and n+3, with n=0,1,2,3;
*An easy way to combine them would be as follows:;
*Make these grps with reverse order;
*Note: use _grp_ to get max;
proc sql noprint;
select max(_grp_) into: mgrp
from &dsdout;

*Add back these bad groups and assign _cgrp_=&mgrp+_n_;
data &dsdout._bad;
retain init_num 1;
set &dsdout._bad;
_cgrp_=&mgrp+_n_;

/*Assume it is better but it is not!;
*Better to group regions with different _cgrp_ together;
*which will aggregate these regions in a single track;
if first._grp_ then do;
  _cgrp_=&mgrp+1;
  init_num=1;
end;
else do;
  init_num=init_num+1;
  _cgrp_=init_num+&mgrp;
end;
by _grp_;
*/
run;


data &dsdout;
set &dsdout &dsdout._bad;
run;

*Note: use _cgrp_ but not _grp_ to get max;
proc sql noprint;
select max(_cgrp_) into: newmgrp
from &dsdout;
/*%abort 255;*/
%if %superq(newmgrp)= %then %let newmgrp=0;

data &dsdout;
set &dsdout;
*Important to adjust group number by not allowing the new _cgrp_ close to original _grp_;
/* if &mgrp-_cgrp_+3 <= _grp_ then _cgrp_=&newmgrp-_cgrp_+1; */
/* if &mgrp-_cgrp_+2 <= _grp_ then _cgrp_=&newmgrp-_cgrp_+1; */
*Put half of these _cgrp_ with larger numbers started from 1;
*This part is a bug if all grps are indeed not mergable, which means there are the same number of orginal and newly generated groups;
%if %sysevalf(&newmgrp>=10) %then %do;
  %put WARNING: the macro adj_grpnum4close_gene_bed_regs will modify the newly created numeric group since it is the same number of groups as the original group;
  if _cgrp_>ceil(0.5*&newmgrp) then _cgrp_=_cgrp_-ceil(0.5*&newmgrp);
%end;
run;

/*
proc sql noprint;
select max(_cgrp_) into: mgrp
from &dsdout;
*Add back these bad groups and assign _cgrp_=&mgrp+1;
data &dsdout._bad;
set &dsdout._bad;
_cgrp_=&mgrp+1;
data &dsdout;
set &dsdout &dsdout._bad;
run;
*/

proc sort data=&dsdout;by _grp_ st end;
*Note that the macro var &old_dsdout is used here to avoid of potential errors when the gene_bed_dsd is the same as &dsdout;
proc sql;
create table &old_dsdout as 
select a.*,b._cgrp_ as &outnumgrp 
from &gene_bed_dsd as a
left join
&dsdout as b 
on a.&gene_grp=b.&gene_grp;

data &dsdout;
set &old_dsdout;
run;
*When the two vars &dsdout and &old_dsdout have the same name, the original dataset will be overwritten;
*Need to keep a copy for it.;
data &old_dsdout.0;
set &old_dsdout;
run;
/*%abort 255;*/
***It is necessary to further optimize these regions by merging the largest group number with the smallest group numer;
***when any regions in the largest group number are not within the distance threshold;

  *This part might invite issues for separating a gene and its corresponding exons into different groups;
  *To resovle the issue, it is necessary use minmum st and max end for each gene_grp as input;
  *First keep a copy for the above &dsdout, and then later update the &outnumgrp with newly calculated group numbers; 
  proc sql;
  create table &dsdout as 
  select distinct &gene_grp,min(&st_var) as &st_var,max(&end_var) as &end_var,&outnumgrp
  from &dsdout
  group by &gene_grp;
/*  %abort 255;*/

%let nmgrp_0=0; 
%let nmgrp_1=1;
*For debugging the loop;
%let nloop=0;
*Restrict the loop only run maximum of 300 iterations;
%do %while (&nmgrp_0 ne &nmgrp_1 and &nloop<300);
   %let nloop=%eval(&nloop+1);
  *Need to create a new numgrp var and reorder the numgrp based on new &outdsd in the loop;
  proc sql;
  create table _tmp_ as
  select unique(&outnumgrp) as _tmpnumgrp_
  from &dsdout
  order by &outnumgrp;
/*  %abort 255;*/
  data _tmp_;set _tmp_;&outnumgrp=_n_;
  proc sql;
  create table &dsdout as
  select a.*,b.&outnumgrp as new&outnumgrp
  from &dsdout as a
  left join
  _tmp_ as b
  on a.&outnumgrp=b._tmpnumgrp_;
/*  %abort 255;*/
  *Put the newnumgrp into the macro var &nmgrps;
  *This will update the macro var nmgrps in each interation;
  proc sql noprint;
  select put(new&outnumgrp,best12.) into: nmgrps separated by ' '
  from (
    select distinct new&outnumgrp from &dsdout
  );
/*  %abort 255;*/
  *Use the newnumgrp to replace older numgrp;
  data &dsdout(rename=(new&outnumgrp=&outnumgrp));
  set &dsdout(drop=&outnumgrp);
  run;

 %if %ntokens(&nmgrps)>=3 %then %do;

   proc sql noprint;
   select put(&outnumgrp,best12.) into: nmgrp_0 separated by ':'
   from &dsdout
   order by &gene_grp, &st_var, &end_var; 
   *Important to only consider the comparision between regions from i and i+2 groups;
   *since the consecutive groups, i and i+1 do not have potential non-overlapped regions based on the distance threshold;

   %do nmg_i=%ntokens(&nmgrps) %to 3 %by -1; 
         *%let start_num=%eval(1+%ntokens(&nmgrps)-&nmg_i);
          %let start_num=1;
		 *Note: only compare 3 pairs, and the following can not be uncommented as SAS will fail to parse the macro contents due to it is use of pcts;
		 %let end_num=%sysfunc(ifc(%eval(&nmg_i-2)>%eval(&start_num+6),%eval(&start_num+6),%eval(&nmg_i-2)));
/*		  %let end_num=%eval(&nmg_i-2);*/
		 %put Your start and end number for the loop is &start_num and &end_num;
	     %do nmg_ii= &start_num %to &end_num %by 2; 
/*		      %let nloop=%eval(&nloop+1);*/
		       %put Running the n=&nloop loop: comparison for the group &nmg_i with group &nmg_ii;
			 data p1;set &dsdout;where &outnumgrp=&nmg_ii;
			 data p2;set &dsdout;where &outnumgrp=&nmg_i;
			 run;
/*			 %if %totobsindsd(work.p2)=0 %then %do;*/
/*						%put No obs in the dataset p2 for the numgrp &nmg_i;*/
/*						%abort 255;*/
/*			 %end;*/
			%if %totobsindsd(work.p2)>0 %then %do;

			 %if %ntokens(&nmgrps)>=3 %then %do;
				 data left;set &dsdout;where &outnumgrp^=&nmg_ii and &outnumgrp^=&nmg_i;
			 %end;
			  run;
/*			  %abort 255;*/
			  *It is important to use distinct to remove duplicate records due to the where condition leads to potential multiple matches;
			  proc sql;
			  create table p1_p2 as
			  select distinct b.*
			  from p1 as a,
			           p2 as b
			  where (b.&st_var between  (a.&st_var-&gene_dist_thrhd) and (a.&end_var+&gene_dist_thrhd)) or 
                         (b.&end_var between  (a.&st_var-&gene_dist_thrhd) and (a.&end_var+&gene_dist_thrhd)); 
/*			   proc print;run;*/
			   %if %totobsindsd(work.p1_p2)>0 %then %do;;			      
					 proc sql;
					 create table p1p2_except as 
					 select * from p2
					 except 
					 select * from p1_p2;
					   data p1p2_except;set p1p2_except;&outnumgrp=&nmg_ii;
					   *Update data set p2, which have different outnumgrp for p1_p2 and p1p2_except;
					   data p2;set p1_p2 p1p2_except;run;
			   %end;
			   %else %do;
			   	  *Merge all records with the largest group &nmg_i as that of &nmg_ii;
			      data p2;set p2;&outnumgrp=&nmg_ii;
			   %end;
			    data &dsdout;
				set p1 p2 
                %if %ntokens(&nmgrps)>=3 %then %do;
				  left
				%end;
                ;
				run;

				proc sql;
				drop table left;
				drop table p1;
				drop table p2;
				drop table p1_p2;
				drop  table p1p2_except;
/*				%abort 255;*/
	      %end;
         %end;
   %end;
  *Capture these new group numbers and order them by positions;
  *The macro var will be used to compare with previous numbers &nmgrp_0;
   proc sql noprint;
   select put(&outnumgrp,best12.) into: nmgrp_1 separated by ':'
   from &dsdout
   order by &gene_grp, &st_var, &end_var; 
%end;
 %else %do;
	 %let nmgrp_0=1; 
     %let nmgrp_1=1;
 %end;

%end;

  *It is necessary to rename the &dsdout as &old_dsdout;
*&old_dsdout contains the target output data set name, in case that it is the same as input data set name;
*Update the newly generated grp number to the &old_dsdout;
/*%put old_dsdout is &old_dsdout and dsdout is &dsdout;*/
proc sql;
create table &old_dsdout as 
select a.*,b.&outnumgrp 
from &old_dsdout.0(drop=&outnumgrp) as a
left join
&dsdout as b
on a.&gene_grp=b.&gene_grp;
/*%abort 255;*/
/* proc print;run; */
%mend;

/* END companion/research/advanced_figures/sources/definitions/adj_grpnum4close_gene_bed_regs.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/adjust_close_positions.sas */
%macro adjust_close_positions(
/*Limitation: where there are only 2 closely related positions, a fixed distance with Pct4OnlyTwoPos*step will be used to separate them;
Additonally, if there are positions too close to the start or end of position in the figure, it is possible to modify the internal macro
var pct2adj4dencluster from 0.25 to larger value but less than 1 at line 90 in the sas macro!
amplification_fc can be increased to separate closely related positions, too!*/
indsd=,
outdsd=,
pos_var=pos,
new_pos_var=newpos,
dist_pct_to_cluster_pos=0.01,/*Use the pct of range of positions to cluster these positions
Note: positions with distance less then ceil(&dist_pct_to_cluster_pos*(max(&pos_var)-min(&pos_var)+1)) will
be asigned into a single cluster for further adjusting distance using amplification_fc!*/
amplification_fc=1.5, /*Increase the distance fold change among these close records;
Note: all positions within the same cluster will be amplified using the formula: pos+(&pos_var-median(&pos_var))*&amplification_fc by cluster*/
make_even_pos=1, /*If provide value 1, which will ensure all position with the same distance between min and max pos;
This will replace previous setting of dist_pct_to_cluster_pos and amplification_fc;
Note: *Only when the total number of records is gt the number of distant cluster, the macro will generate even positions for all records
*/
pct2adj4dencluster=0.05,/*This parameter is mainly designed when make_even_pos=0; it is useful when elements within a cluster is overlapped with each other
or overlapped with elements from other cluster, so it is feasible to avoid this issue by increasing the pct or reducing it.
However, when make_even_pos=1, the macro will multiple the amplification_fc with 10*pct2adj4dencluster to further enlarge the even distance among positions*/
Pct4OnlyTwoPos=0.5,/*In case of only two positions, it is necessary to use arbitrary proportion of dist_step to separate them,
i.e., minus and add Pct4OnlyTwoPos*dist_step and for the first and second positions, respectively*/
fixed_min_pos=,/*Provide fixed minimum and maximum positions for generating even psotions;
Default is empty to use the minimum and maximum positions from input dsd!*/
fixed_max_pos=
);

proc sql noprint;
select count(unique(&pos_var)) into: tot_rows
from &indsd;

select min(&pos_var),max(&pos_var),
ceil(&dist_pct_to_cluster_pos*(max(&pos_var)-min(&pos_var)+1)),
min(&pos_var), max(&pos_var), 
(max(&pos_var)-min(&pos_var)+1)/(1+&tot_rows)
into: min_pos,:max_pos,
:offset_dist,
:min_pos,:max_pos,
:dist_step
from &indsd;
quit;

%if %length(&fixed_min_pos)>0 %then %let min_pos=&fixed_min_pos;
%if %length(&fixed_max_pos)>0 %then %let  max_pos=&fixed_max_pos;
%let dist_step=%sysevalf((&max_pos-&min_pos+1)/(1+&tot_rows));

*Need to update the macro var offset_dist as min_pos and max_pos might be changed;
%let offset_dist=%sysevalf(&dist_pct_to_cluster_pos*(&max_pos-&min_pos+1));

proc sort data=&indsd out=&outdsd nodupkeys;by &pos_var;run;
/* proc print;run; */


data &outdsd(drop=_pre_pos_);
retain _pre_pos_ dist_cluster 0;
set &outdsd;
ord=_n_;
if _n_=1 then do;
   dist_cluster=1;
   _pre_pos_=&pos_var;
   output;
end;
*This means that two positions with distance less than the offset_dist will be assigned with the same cluster number;
if _n_>1 and &pos_var-_pre_pos_<&offset_dist then do;
    _pre_pos_=&pos_var;
    dist_cluster=dist_cluster;
    output;
 end;
 else if _n_>1 then do;
    _pre_pos_=&pos_var;
    dist_cluster=dist_cluster+1;
    output;
 end;
run;
/* proc print;run; */


/* %let amplification_fc=1.5; */
*Note that if these positions within a cluster are too close, the adjusted position by only adding or minusing median(pos) would fail to separate positions;
*So by including the ratio between distance between positions within a cluster to the average positions in the cluster to the offset_dist and further reduce it by 10 fold;
*these positions will be separated from each other;

*Note: that it is necessary to use median pos as a separator to add or substract offset distances among positions within a cluster;
*the function avg fails to separate the most closest positions in each cluster, as these position tend to be not changed in scale in the final output;


*Note that the extra amplification factor 0.1*&offset_dist/abs(&pos_var-median(&pos_var)) is not multiplied for _pos_;
*Instead, we multiple it with the new factor: 10*pct2adj4dencluster; 
proc sql;
create table &outdsd._with_close_records as
select dist_cluster,&pos_var,ord,
&pos_var+(&pos_var-median(&pos_var))*&amplification_fc*(10*&pct2adj4dencluster) as _pos_
from &outdsd
group by dist_cluster
having count(dist_cluster)>1
order by ord;
/*proc print;run;*/
/*%abort 255;*/

*Now update the positions in the output data set;
proc sql;
create table &outdsd as
select *
from &outdsd
natural full join
&outdsd._with_close_records
;
*This will keep duplicate records in the outdsd;
proc sql;
create table &outdsd as
select *
from &indsd
natural full join
&outdsd;


proc sort data=&outdsd;by ord;
proc sql noprint;
select max(dist_cluster) into: max_cluster
from &outdsd;

data &outdsd(rename=(_pos_=&new_pos_var) );
set &outdsd;
if _pos_=. then _pos_=&pos_var;
/*drop=dist_cluster ord;*/
run;
/*proc print;run;*/

*Only when the total number of records is gt the number of distant cluster, the macro will generate even positions for all records;
%if &make_even_pos=1 and  &max_cluster^=&tot_rows %then %do;
data &outdsd;
set &outdsd;
&new_pos_var=&min_pos+ord*&dist_step;
run;
%end;


proc sql;
drop table &outdsd._with_close_records;
quit;
/* proc print;run; */

*The above will failed to revise the positions of markers if the total number of which is 2;
*The following code will update these positions specifically for the above scenario;
proc sql noprint;
select count(*) into: _tot_rescaled_pos_
from &outdsd;
%if &_tot_rescaled_pos_=2 %then %do;
data &outdsd;
set &outdsd;
if _n_=1 then do;
/*  &new_pos_var=&new_pos_var-0.1*&dist_step;*/
  &new_pos_var=&new_pos_var-&Pct4OnlyTwoPos*&dist_step;
end;
else do;
/*  &new_pos_var=&new_pos_var+0.1*&dist_step;*/
  &new_pos_var=&new_pos_var+&Pct4OnlyTwoPos*&dist_step;
end;
run;
%end;
/*proc print;run;*/
*Further correct the minimum and maximum value in the outpu data set;
data &outdsd;
set &outdsd;
if &new_pos_var<&min_pos then &new_pos_var=&pos_var-(&max_pos-&min_pos)*0.05;
if &new_pos_var>&max_pos then &new_pos_var=&pos_var+(&max_pos-&min_pos)*0.05;
run;
*Further separate positions that are too close based on the  cutoff 0.1*&dist_step;
data &outdsd(drop=_new_pos_var_);
set &outdsd;
  if &new_pos_var-lag(&new_pos_var)<0.5*&dist_step  then do;
   if first.dist_cluster then do;
     _new_pos_var_=lag(&new_pos_var)+0.5*&dist_step;
   end;
   else do;
	 _new_pos_var_=lag(&new_pos_var)+0.25*&dist_step;
   end;
  end;
  if _new_pos_var_^=.  then &new_pos_var=_new_pos_var_;
  by dist_cluster;
run;
/*proc print;run;*/
/*%abort 255;*/

%mend;

/* END companion/research/advanced_figures/sources/definitions/adjust_close_positions.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/bed_region_plot_by_grp.sas */
%macro bed_region_plot_by_grp(
bed_dsd,
chr_var,
st_var,
end_var,
grp_var,
yval_var,
linethickness=20,
track_width=800,
track_height=400,
dist2st_and_end=0
);
%number_rows_by_grp(dsdin=&bed_dsd,grp_var=&grp_var,num_var4sort=&st_var,descending_or_not=0,dsdout=x1);
data x1(keep=&chr_var pos &yval_var &grp_var ord st end);
set x1;
array X{2} &st_var &end_var;
do i=1 to 2;
 pos=X{i};
 output;
end;
run;
/*Get max grp number for split data into different dsd*/;
proc sql noprint;
select max(ord),floor(min(&yval_var)),ceil(max(&yval_var)),min(&st_var)-&dist2st_and_end,max(&end_var)+&dist2st_and_end 
       into: max_ord,: min_y,: max_y,: min_x,: max_x
from x1;
%if %eval(&min_x<0) %then %do;
    %let min_x=0;
%end;
/*
data tmp;
set x1(keep=&grp_var &yval_var);
proc sort data=tmp nodupkeys;by &yval_var &grp_var;
run;
proc sql noprint;
select quote(&grp_var) into: y_grp_values separated by " "
from tmp
order by &yval_var;
drop table tmp;
*/

data tmp;
do i=&min_y to &max_y;
output;
end;
run;
proc sql noprint;
select i into: y_axis_values separated by " "
from tmp;
drop table tmp;

/***********************No need this, as it generates missing group that will be put into the legend
in in the final figure*/
/*data x1;*/
/*set x1;*/
/*%do i=1 %to &max_ord;*/
/*if ord=&i then do;*/
/*  &grp_var.&i=&grp_var;*/
/*  pos&i=pos;*/
/*  &yval_var.&i=&yval_var;*/
/*  output;*/
/*end;*/
/*%end;*/
/*run;*/
/************************************************************************************************/


/*Need to fill these missing values with pair of non-missing values,
otherwise, the missing values will be a group that will be included 
in the legend in the final figure*/
%do gi=1 %to &max_ord;
data y&gi(keep=ord &grp_var&gi pos&gi &yval_var&gi);
set x1;
if ord=&gi then do;
  &grp_var&gi=&grp_var;
  pos&gi=pos;
  &yval_var&gi=&yval_var;
  output;
end;
else do;
  /*grp_var may be numeric or char, 
   just use its original value here,
   will remove it later*/
  &grp_var&gi=&grp_var;
  pos&gi=.;
		label pos&gi="Relative position (bp)";
  &yval_var&gi=.;
		label &yval_var&gi="Group";
  output;
end;
run;

/*proc sort data=y&gi;by &grp_var&gi ord pos&gi;*/
/*run;*/

/*get the 1st two records without missing values,
which will be used for fill these missing values later*/
data y&gi._ y&gi._missing;
set y&gi;
if pos&gi^=. then output y&gi._;
else output y&gi._missing;
/*create the common var n with values of 1 or 2
for matching with non-missing values from y1_*/
data y&gi._missing;
set y&gi._missing;
if mod(_n_,2)=0 then n=2;
else n=1;
/*Also get the 1st two non-missing values and 
label them with 1 and 2 for matching*/
data y&gi._1;
set y&gi._;
n=_n_;
if _n_<=2;
run;
proc sql;
create table y&gi._filled as
select a.n as n&gi, b.*
from y&gi._missing as a,
     y&gi._1 as b
where a.n=b.n;
/*merge y1_filled with y1_*/
data y&gi._final(drop=ord n);
set y&gi._filled(drop=n&gi) y&gi._;
run;
%end;

data final;
%do i=1 %to &max_ord;
set y&i._final;
%end;
run;
*documentation for adjusting axis for layout overlay;
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatug/p1pqfzgbuzbpkzn1mrbzhgggvhkz.htm;
proc template;
define statgraph Bedgraph;
dynamic _chr _pos _value _G;
begingraph / designwidth=&track_width designheight=&track_height;
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
         layout overlay/yaxisopts=(
                        type=linear offsetmin=0.1 offsetmax=0.1
                        linearopts=(minorticks=false tickvaluelist=(&y_axis_values))
                        )
                        xaxisopts=(linearopts=(viewmin=&min_x viewmax=&max_x));
                        /* Need to add this into linearopts later: tickdisplaylist=(&y_grp_values)*/
		 %do i=1 %to &max_ord;
	       %if &i=1 %then %do;
		     referenceline y=0 /lineattrs=(color=black pattern=1 thickness=2);
						%if &min_y<0 %then %do;
						  %do _yi_=&min_y %to -1;
		       referenceline y=&_yi_ /lineattrs=(color=black pattern=2 thickness=0.5);
								%end;
						%end;
						%else %do;
						  %do yi=1 %to &max_y;
		        referenceline y=&yi /lineattrs=(color=black pattern=2 thickness=0.5);
								%end;
						%end;
		   %end;

               seriesplot x=pos&i y=&yval_var.&i / group=&grp_var.&i name='series' connectorder=xaxis 
                                      lineattrs=(pattern=SOLID thickness=&linethickness)
                                      name="series&i"
                                      ;
         %end;	
      endlayout; 
	  sidebar /align=bottom;
	  discretelegend "series1"; 
	  endsidebar;
   endlayout;
endgraph;
end;
run;

proc sgrender data=WORK.final template=BedGraph;
dynamic _chr="&chr_var";
run;

%mend;

/* END companion/research/advanced_figures/sources/definitions/bed_region_plot_by_grp.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/beta2OR_forest_plot.sas */
%macro Beta2OR_forest_plot(
dsdin=,
beta_var=,
se_var=,
sig_p_var=,/*adjust the threshold of p in the extra_condition4updatedsd*/
marker_var=,
marker_label=,
svgoutname=,
plot_title=OR Forest Plot,
figfmt=png,
figwidth=600,
figheight=800,
dotsize=10,
autolegend=0,
xaxis_value_range=%str(0.4 to 1.6 by 0.2),
sort_var4y=,/*Provide a variable in the input dsdin to sort the y axis tickets in the final figure;
1. If left empty, it will use the default data order of marker_var to label y-axis from lower to upper;
The default order of data can be modified by using proc sort procedure as follows:
proc sort data=tops;by type gwas2_beta rsid;run;
This is powerful because multiple variables can be used to sort the final y-axis tickets;
2. Alternatively, it is fine to use a new variable, as sometimes it is better to create 
a new variable for sorting the input dsdin before applying the current macro
*/
y2axis_ticket_var=,/*Default is emptyp to not to draw the 2nd yaxis;
Provide a variable name to use its values to draw the 2nd yaxis*/
both_y_font_size=12, /*Font size for any of the two y-axis*/
sig_datalabel_pos=,
sig_datalabel_size=,
min_axis=0,
max_axis=2,
yoffsetmax=0.03, /*offset for the upper y axis maximum value*/
yoffsetmin=0.03, /*offset for the lower y axis minimum value*/
y_refline_values=,
y_refline_lineattrs=%str(pattern=shortdash color=gray thickness=1),
randomize_output_suffix=1,
output_suffix=,
/*Note: the macro need to have a input variable grp to color dots representing OR;
So in the following extra condition for input dataset, a new variable grp is created.*/
outdsd=dsd4OR,/*Output calcuated ORs for further evaluation*/
extra_condition4updatedsd=%nrstr(
length sigtag $10.;
if &marker_var="rs16831827" then do;
 grp=0;sigtag='';
end;
else if &sig_p_var<5e-8 then do;
 grp=1;sigtag='*';
end;
else do;
 grp=1;sigtag="";
end;
if &marker_var="12:113357193:G:A" then &marker_var="rs10774671";
if &marker_var="17:44219831:T:A" then &marker_var="rs1819040";
if &marker_var="19:10427721:T:A" then &marker_var="rs74956615";

if &marker_var in ('rs2271616','rs11919389','rs912805253','rs4801778') then grp=0;
else if &marker_var='rs16831827' then grp=1;
else grp=2;
 )
);

%local _forest_output_suffix _forest_output_stub _forest_output_stub_norm _forest_image_name _forest_output_dir _forest_printer_device;
%if %length(&sig_datalabel_size)=0 %then %let sig_datalabel_size=&both_y_font_size;
%if %length(&output_suffix)>0 %then %do;
  %let _forest_output_suffix=&output_suffix;
%end;
%else %if %sysevalf(&randomize_output_suffix ne 0) %then %do;
  %let _forest_output_suffix=%RandBetween(1,100);
%end;
%else %do;
  %let _forest_output_suffix=;
%end;
%let _forest_output_stub=&svgoutname;
%if %length(&_forest_output_suffix)>0 %then %let _forest_output_stub=&svgoutname.&_forest_output_suffix;
%let _forest_output_stub_norm=%sysfunc(tranwrd(%superq(_forest_output_stub),%str(\),/));
%let _forest_image_name=%sysfunc(scan(%superq(_forest_output_stub_norm),-1,%str(/)));
%let _forest_output_dir=%sysfunc(prxchange(s/\/[^\/]+$//,1,%superq(_forest_output_stub_norm)));
%if %superq(_forest_output_dir)=%superq(_forest_output_stub_norm) %then %let _forest_output_dir=.;
%let _forest_printer_device=%lowcase(&figfmt);
%if %length(&_forest_printer_device)=0 %then %let _forest_printer_device=png;

data tmp;
set &dsdin;
effect=exp(&beta_var);
uppercl=exp(&beta_var+1.96*&se_var);
lowercl=exp(&beta_var-1.96*&se_var);
%unquote(&extra_condition4updatedsd);
run;

ods listing close;
ods listing gpath="&_forest_output_dir";

%if %length(&plot_title)>0 %then %do;
title "&plot_title";
%end;
%else %do;
title;
%end;
ods graphics on/reset=all noborder outputfmt=&figfmt
                            width=&figwidth height=&figheight
                            imagename="&_forest_image_name";
data _tmp_;
set tmp;
keep by_n &marker_var;
%if %length(&sort_var4y)=0 %then %do;
   by_n=_n_;
%end;
%else %do;
  by_n=&sort_var4y;
%end;
run;

%mkfmt4grps_by_var(
grpdsd=_tmp_,
grp_var=&marker_var,
by_var=by_n,
outfmt4numgrps=x2y,
outfmt4chargrps=y2x
);

data tmp;
set tmp;
*format char grps to numeric grps;
new_grp_var=input(&marker_var,x2y.);
run;

***********Import attrmap to assign the same color schemes to different grp*****************************;
/*https://blogs.sas.com/content/iml/2017/01/30/auto-discrete-attr-map.html*/
%let VarName = grp;           /* specify name of grouping variable */
proc freq data=tmp ORDER=FORMATTED noprint;   /* or ORDER=DATA|FREQ  */
   tables &VarName / out=Attrs(rename=(&VarName=Value));
run;
data DAttrs;
ID = "&VarName";                 /* or "ID_&VarName" */
set Attrs(keep=Value);
length MarkerStyleElement $11.;
MarkerStyleElement = cats("GraphData", 1+mod(_N_-1, 12)); /* GraphData1, GraphData2, etc */
run; 
/*proc print; run;*/
***********The above codes are important to assign the same color schemes to different grp*********;


proc sgplot data=tmp dattrmap=DAttrs %if &autolegend=0 %then noautolegend;;
/* scatter x=effect y=&marker_var / datalabel=sigtag */
scatter x=effect y=new_grp_var / datalabel=sigtag 
datalabelattrs=(size=&sig_datalabel_size weight=bold)
%if %length(&sig_datalabel_pos)>0 %then %do;
datalabelpos=&sig_datalabel_pos
%end;
group=grp xerrorlower=lowercl  grouporder=ASCENDING attrid=grp
xerrorupper=uppercl	 name="dotsc"
markerattrs=(symbol=circleFilled size=&dotsize);
*https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/grstatproc/p0er4dg9tojp05n1sf7maeqdz1d8.htm;
refline 1 / axis=x lineattrs=(pattern=solid color=darkgray thickness=1) ;
xaxis label="OR and 95% CI " labelattrs=(size=&both_y_font_size) min=&min_axis valueattrs=(size=&both_y_font_size) max=&max_axis values=(&xaxis_value_range);
*It is necessary to add the type=discrete to fix the yaxis using the newly created new_grp_var with its numeric format;
yaxis label="&marker_label" labelattrs=(size=&both_y_font_size) valueattrs=(size=&both_y_font_size style=normal) type=discrete display=(nolabel)
          offsetmax=&yoffsetmax offsetmin=&yoffsetmin;
%if %length(&y_refline_values)>0 %then %do;
refline &y_refline_values / axis=y lineattrs=(&y_refline_lineattrs);
%end;

*Align labels to SNP rows so repeated genes or NA values cannot collapse categories;
%if %length(&y2axis_ticket_var)>0 %then %do;
yaxistable &y2axis_ticket_var / y=new_grp_var position=right location=outside
  nolabel valueattrs=(size=&both_y_font_size style=italic);
%end;

%if &autolegend=1 %then %do;
keylegend "dotsc"/ title="";
%end;

format new_grp_var y2x.;
run;
ods listing;
title;

data &outdsd;
set tmp;
run;

%mend;

/* END companion/research/advanced_figures/sources/definitions/beta2OR_forest_plot.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/char_grp_to_num_grp.sas */
%macro char_grp_to_num_grp(
dsdin=,
grp_vars4sort=,
descending_or_not=,
dsdout=,
num_grp_output_name=,
keep_uniq_rows_by_grp=0
);
/*Note: if keep_uniq_rows_by_grp=1, then only unique grps will be remained in the final dataset*/
%let nvars=%numargs(&grp_vars4sort);
*Use key instead of by in the proc sort, as unknown error occurred when using by with descending function;
*Note: if &dsdin and &dsdout are the same, the final &dsdout will only contain unique rows by keys;
*This would be wrong if wanting to keep all rows!;
*So only use the temporary table dsdout here;
%if &descending_or_not %then %do;
proc sort data=&dsdin nodupkeys out=dsdout;
key &grp_vars4sort /descending;
run;
%end;
%else %do;
proc sort data=&dsdin nodupkeys out=dsdout;
key &grp_vars4sort;
run;
%end;

data dsdout;
set dsdout;
&num_grp_output_name=_n_;
%if &nvars>=1 %then %do;
grps_output_key=catx(':', of &grp_vars4sort);
%end;
run;
/*Only unique grp keys are kept in the above output dsd!*/

%if %eval(&keep_uniq_rows_by_grp=0) %then %do;
*Now add the num_grp_output_name back to the original table;
data tmp;
set &dsdin;
_grps_output_key_=catx(':', of &grp_vars4sort);
run;
proc sql;
create table &dsdout(drop=_grps_output_key_) as
select b.*,a.&num_grp_output_name,a.grps_output_key
from dsdout as a
right join
tmp as b
on a.grps_output_key=b._grps_output_key_;
%end;
%else %do;
data &dsdout;
set dsdout;
run;
%end;
%mend;

/* END companion/research/advanced_figures/sources/definitions/char_grp_to_num_grp.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/check_var_type.sas */
%macro check_var_type(dsdin,var_rgx);
proc contents data=&dsdin out=&dsdin._fmt noprint;
run;
proc sql noprint;
/*select distinct(TYPE) into: var_type separated by '|'*/
select TYPE into: var_type separated by '|'
from &dsdin._fmt
where prxmatch("/&var_rgx/i",NAME);

%put The types of variables matched with regular expression &var_rgx in dsd &dsdin are:;
%put &var_type;
%if %index(&var_type,|) %then %put Your regular expression matchs with >1 variables, please restrict your regular expression to only match with a unique variable name;

%mend;

/* END companion/research/advanced_figures/sources/definitions/check_var_type.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/delete_empty_dsd.sas */
%macro delete_empty_dsd(dsd_in);
%if (%sysfunc(count(&dsd_in,%str(.)))>0) %then %do;
%let lib=%scan(&dsd_in,1,'.');
%let dsd_in=%scan(&dsd_in,2,'.');
%end;
%else %do;
%let lib=work;
%end;
proc sql noprint;
select count(*)
into: obs_num
from &lib..&dsd_in;
%if (&obs_num=0) %then %do;
proc datasets lib=&lib nolist;
delete &dsd_in;
run;
%put "The dataset &dsd_in in the library &lib is empty!";
%put "The above dataset is deleted!";
%end;
%mend;

/* END companion/research/advanced_figures/sources/definitions/delete_empty_dsd.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/format_xaxis_with_numeric_order.sas */
%macro format_xaxis_with_numeric_order(
dsdin,
Xaxis_vars,
new_Xaxis_var,
Var4sorting_Xaxis,
function4sorting,
descending_or_not,
dsdout,
createdfmtname,
KeyVar4Xaxis_vars=KeyVar4dsdout
);

*If AlsoAppFun4Cols=1, will apply specific function on each row or ALL Rows (if row_keys is missing) for ALL these matched columns;
*For AlsoAppFun4Cols=1, we can not use avg but mean, because avg is going to calculate mean based on group and mean is to calculate mean of different columns;
*Should be careful to use this function to calculate mean of ALL data points.;
*Note: KeyVar4dsdout will try to catx all row_keys with ':';
%ApplyFunc_rowwide(dsdin=&dsdin
                  ,row_keys=&Xaxis_vars
                  ,KeyVar4dsdout=KeyVar4dsdout
                  ,Regex4col_vars2apply=&Var4sorting_Xaxis
				  ,SQL_Fun4apply=&function4sorting
                  ,dsdout=Sorted_dsd
                  ,AlsoAppFun4Cols=1);
%put Xaxis_vars are &Xaxis_vars;

*Add numeric grp id to each grp with the order in accordace with the summary of &var4sorting after applied for the function &function4sorting by grp;
*New variable &function4sorting will be created, which can be used to sort the new variable dataset;
*If supplying ONE or multiple vars into grp_vars4sort, a default new var combining all these vars with ':' will be created;
*which is grps_output_key;
%char_grp_to_num_grp(dsdin=Sorted_dsd,grp_vars4sort=&function4sorting KeyVar4dsdout,descending_or_not=&descending_or_not,dsdout=Sorted_dsd1,num_grp_output_name=&new_Xaxis_var);

/*catx Xaxis_vars*/
data var_labels;
set Sorted_dsd1;
*remove leading grp generated by supplied function;
grps_output_key=prxchange('s/^[^:]+://',-1,grps_output_key);
keep grps_output_key &new_Xaxis_var KeyVar4dsdout;
run;

proc sql noprint;
select count(grps_output_key), catx('','grp',count(grps_output_key)) into: vtot, : grp_v
from var_labels;
select grps_output_key into: vvgrp1 - : vv&grp_v
from var_labels;

*Print it for debugging;
%do xi=1 %to &vtot; 
   %put Apply format for &xi="&&vvgrp&xi";
%end;

*Delete previous format, otherwise the new format will not be applied;
/*
proc format lib=work fmtlib;
run;
*/

proc catalog cat=work.formats;
delete &createdfmtname..format;
run;

proc format;
value &createdfmtname 
%do i=1 %to &vtot; 
        &i="&&vvgrp&i"
%end;
;
data &dsdin;
set &dsdin;
KeyVar4dsdout=catx(':',of &Xaxis_vars);
run;

proc sql;
create table &dsdin._tmp as
select a.*,
       b.&new_Xaxis_var,
       b.grps_output_key
from &dsdin as a
left join
var_labels as b
on strip(left(a.KeyVar4dsdout))=strip(left(b.KeyVar4dsdout))
;

*This actually not helpful;
data &dsdout;
set &dsdin._tmp;
num_grp=&new_Xaxis_var;
/*Will change it manually outside the macro later*/
attrib &new_Xaxis_var format=&createdfmtname..;
run;

*Note: new evaluation revealed that the above format is not useful;
*The variable KeyVar4Xacis_vars can not used to draw plot with numeric order directly.;
proc sort data=&dsdout;by num_grp;run;
data &dsdout;
set &dsdout;
rename KeyVar4Xaxis_vars=&KeyVar4Xaxis_vars;
run;

%mend;

/* END companion/research/advanced_figures/sources/definitions/format_xaxis_with_numeric_order.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/get_tgt_hits4Manhattan.sas */
%macro get_tgt_hits4Manhattan(/*Note: the macro is able to keep the order of target snps and generate a macro var
called _chr_colors_ according to the chromsomes that these input snps residing in!*/
dsdin=_last_,
snp_var=rsid,
chr_var=chr,
pos_var=pos,
p_var=p,
dsdout=tophits,
target_snps=rs2564978 rs17425819, /*Only focus on regions of these target snps*/
keep_target_snps_order=0,/*Supply value 1 to keep the original input order of target SNPs, otherwise, 
the macro will sort the input target SNPs and also sort _chr_colors_ by sorted SNPs!*/
dist4get_uniq_top_hit=1e6 /*Only get the top one hit among the distance by pos with the top one at the center*/
);

*Note: this global macro var will be used to draw Manhattan plot later;
%global _chr_colors_;
%let _chr_colors_=;

%let _grp_cols_=
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319;

%rank4grps(
grps=&_grp_cols_,
dsdout=grpcolsdsd
);

data grpcolsdsd;
set grpcolsdsd;
rename num_grps=&chr_var;
              cls=grps;
run;

%rank4grps(
grps=&target_snps,
dsdout=tgts
);
data tgts;
set tgts;
rename grps=&snp_var;
run;
*Also keep the order of input SNPs by keeping the variable num_grps;
proc sql;
create table top_ind as
select a.*,b.num_grps
from &dsdin as a,
         tgts as b
where a.&snp_var=b.&snp_var;

proc sql;
   create table &dsdout as 
   select a.*,b.&snp_var as tag_snp,b.num_grps
   from &dsdin as a,
            top_ind as b
 where a.&chr_var=b.&chr_var and 
a.&pos_var between (b.&pos_var-0.5*&dist4get_uniq_top_hit) and 
                                     (b.&pos_var+0.5*&dist4get_uniq_top_hit); 


*Now try to match colors for these top hits by chr;
%if &keep_target_snps_order=1 %then %let var4srt_snp=num_grps;
%else %let var4srt_snp=tag_snp;
proc sql noprint;
create table &dsdout as
select a.*,b.cls
from &dsdout as a
left join
grpcolsdsd as b
on a.&chr_var=b.&chr_var;

select distinct cls into: _chr_colors_ separated by ' '
from &dsdout 
order by &var4srt_snp;

%if %totobsindsd(mydata=&dsdout)=0 %then %do;
    *Do not kill the macro as this macro may be used by a macro loop within other macros;
		%put No targets for your quiry snps: &target_snps;
/*    %abort 255;*/
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/get_tgt_hits4Manhattan.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/get_top_hits4Manhattan.sas */
%macro get_top_hits4Manhattan(
dsdin=_last_,
snp_var=rsid,
chr_var=chr,
pos_var=pos,
p_var=p,
dsdout=tophits,
p_thrsd=1e-5, /*Only keep these signals with smaller values than the threshold*/
dist4get_uniq_top_hit=1e6, /*Used only as an LD-query failure fallback when selection_method=LD*/
selection_method=LD,
ld_pops=EUR,
ld_r2_threshold=0.1,
ld_population_rule=ANY,
ld_query_failure_action=DISTANCE,
max_leads=0,
ld_audit_out=top_hit_ld_audit
);
*Note: these global macro vars will be used to draw Manhattan plot later;
%global _chr_colors_ _top_snps_;
%let _chr_colors_=;
%let _top_snps_=;

%let _grp_cols_=
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319
cxedb120
cx7e2f8e
cx77ac30
cx4dbeee
cxa2142f
cx0072bd
cxd95319;

%rank4grps(
grps=&_grp_cols_,
dsdout=grpcolsdsd
);

data grpcolsdsd;
set grpcolsdsd;
rename num_grps=&chr_var;
              cls=grps;
run;

proc sql;
create table _top_hits as
select * 
         from &dsdin
         where not missing(&p_var)
           and &p_var > 0
           and &p_var <= &p_thrsd;
quit;

%put NOTE: get_top_hits4Manhattan is selecting candidate hits with &p_var <= &p_thrsd.;

%if %upcase(&selection_method)=LD %then %do;
  %get_top_signal_with_ld(
    dsdin=_top_hits,
    snp_var=&snp_var,
    grp_var=&chr_var,
    signal_var=&p_var,
    select_smallest_signal=1,
    pos_var=&pos_var,
    signal_thrshd=&p_thrsd,
    ld_pops=&ld_pops,
    ld_r2_threshold=&ld_r2_threshold,
    ld_population_rule=&ld_population_rule,
    query_failure_action=&ld_query_failure_action,
    fallback_dist_bp=&dist4get_uniq_top_hit,
    max_leads=&max_leads,
    dsdout=top_ind,
    audit_out=&ld_audit_out
  );
%end;
%else %do;
  %get_top_signal_within_dist(
    dsdin=_top_hits,
    grp_var=&chr_var,
    signal_var=&p_var,
    select_smallest_signal=1,
    pos_var=&pos_var,
    pos_dist_thrshd=&dist4get_uniq_top_hit,
    dsdout=top_ind,
    signal_thrshd=&p_thrsd
  );
%end;
proc sql noprint;
select count(*) into: _top_snp_n trimmed
from top_ind;
quit;
%put NOTE: get_top_hits4Manhattan retained &_top_snp_n lead SNPs after &selection_method selection.;

proc sql outobs=200 noprint;
select &snp_var into: _top_snps_ separated by ' '
from top_ind
order by &snp_var;
%put Top snps are selected: &_top_snps_;
%if %sysevalf(%superq(_top_snp_n) > 200) %then %do;
  %put NOTE: &_top_snp_n top SNPs passed the threshold, and _top_snps_ is truncated to the first 200 names to avoid macro-length overflow.;
%end;
%else %do;
  %put They are saved into a global macro variable, _top_snps_;
%end;

proc sql;
   create table &dsdout as 
   select a.*,b.&snp_var as tag_snp
   from &dsdin as a,
            top_ind as b
 where a.&chr_var=b.&chr_var and 
a.&pos_var between (b.&pos_var-0.5*&dist4get_uniq_top_hit) and 
                                     (b.&pos_var+0.5*&dist4get_uniq_top_hit); 


*Now try to match colors for these top hits by chr;
proc sql noprint;
create table &dsdout as
select a.*,b.cls
from &dsdout as a
left join
grpcolsdsd as b
on a.&chr_var=b.&chr_var;

select distinct cls into: _chr_colors_ separated by ' '
from &dsdout 
order by tag_snp;
%put Colors for top snps are &_chr_colors_;
%put They are sorted by snps and saved into a global macro variable, _chr_colors_;

%if %totobsindsd(mydata=&dsdout)=0 %then %do;
		%put No hits after filtering with the p value threshold &p_thrsd;
/*    %abort 255;*/
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/get_top_hits4Manhattan.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/get_top_signal_with_ld.sas */
%macro get_top_signal_with_ld(
  dsdin=,
  snp_var=SNP,
  grp_var=CHR,
  signal_var=P,
  select_smallest_signal=1,
  pos_var=BP,
  signal_thrshd=1,
  ld_pops=EUR,
  ld_r2_threshold=0.1,
  ld_population_rule=ANY,
  query_failure_action=DISTANCE,
  fallback_dist_bp=1e6,
  max_leads=0,
  dsdout=top_ind,
  audit_out=top_hit_ld_audit
);
%local _candidate_n _iter _remaining_n _lead_id _lead_snp _lead_chr
       _lead_query_snp _lead_bp _lead_signal _lead_is_rs _pop_n _pi _pop _valid_pop_n
       _requested_pop_n _response_valid _response_self_n _selected_n
       _rule _failure_action _max_leads_num _has_rsid _has_r2 _cache_pop_n
       _lead_query_status;
%global TOP_HIT_LD_SELECTION_STATUS TOP_HIT_LD_SELECTED_N TOP_HIT_LD_PRUNED_N;

%let TOP_HIT_LD_SELECTION_STATUS=RUNNING;
%let TOP_HIT_LD_SELECTED_N=0;
%let TOP_HIT_LD_PRUNED_N=0;
%let _rule=%upcase(%sysfunc(strip(%superq(ld_population_rule))));
%let _failure_action=%upcase(%sysfunc(strip(%superq(query_failure_action))));
%let _requested_pop_n=%sysfunc(countw(%superq(ld_pops),%str( )));
%let _max_leads_num=%sysfunc(inputn(%superq(max_leads),best32.));
%if %sysevalf(%superq(_max_leads_num)=,boolean) %then %let _max_leads_num=0;

%if &_requested_pop_n=0 %then %do;
  %put ERROR: get_top_signal_with_ld requires at least one HaploReg population in ld_pops=.;
  %let TOP_HIT_LD_SELECTION_STATUS=INVALID_LD_POPULATIONS;
  %return;
%end;
%if &_rule ne ANY and &_rule ne ALL %then %do;
  %put ERROR: ld_population_rule must be ANY or ALL, not &ld_population_rule.;
  %let TOP_HIT_LD_SELECTION_STATUS=INVALID_POPULATION_RULE;
  %return;
%end;

data _ld_candidates_unsorted;
  set &dsdin;
  length _ld_snp_key $128 _ld_chr_key $32;
  length _ld_signal _ld_bp_num 8;
  _ld_snp_key=upcase(strip(vvalue(&snp_var)));
  _ld_chr_key=upcase(compress(strip(vvalue(&grp_var)),' '));
  _ld_chr_key=prxchange('s/^CHR//i',1,_ld_chr_key);
  _ld_bp_num=input(strip(vvalue(&pos_var)),best32.);
  _ld_signal=input(strip(vvalue(&signal_var)),best32.);
  if missing(_ld_snp_key) or missing(_ld_chr_key) or missing(_ld_bp_num) then delete;
  if missing(_ld_signal) or _ld_signal <= 0 or _ld_signal > &signal_thrshd then delete;
run;

proc sort data=_ld_candidates_unsorted out=_ld_candidates_ranked;
%if &select_smallest_signal=1 %then %do;
  by _ld_signal _ld_chr_key _ld_bp_num _ld_snp_key;
%end;
%else %do;
  by descending _ld_signal _ld_chr_key _ld_bp_num _ld_snp_key;
%end;
run;

data _ld_candidates;
  if _n_=1 then do;
    declare hash _seen();
    _seen.defineKey('_ld_snp_key');
    _seen.defineDone();
  end;
  set _ld_candidates_ranked;
  if _seen.check()=0 then delete;
  _seen.add();
  length _ld_pruned_by $128 _ld_prune_population $32
         _ld_query_status $24 _ld_independence_method $24;
  retain _ld_candidate_id 0;
  _ld_candidate_id+1;
  _ld_selected=0;
  _ld_pruned=0;
  _ld_lead_rank=.;
  _ld_pruned_lead_rank=.;
  _ld_prune_r2=.;
run;

proc sql noprint;
  select count(*) into :_candidate_n trimmed from _ld_candidates;
quit;
%if %sysevalf(%superq(_candidate_n)=,boolean) %then %let _candidate_n=0;

%if &_candidate_n=0 %then %do;
  data &dsdout; set _ld_candidates; run;
  data &audit_out;
    length candidate_snp lead_snp $128 selection_action $24;
    stop;
  run;
  %let TOP_HIT_LD_SELECTION_STATUS=NO_CANDIDATES;
  %goto _ld_cleanup;
%end;

%do _iter=1 %to &_candidate_n;
  %let _remaining_n=0;
  %let _lead_id=;
  %let _lead_snp=;
  %let _lead_query_snp=;
  %let _lead_chr=;
  %let _lead_bp=;
  %let _lead_signal=;
  proc sql noprint;
    select count(*) into :_remaining_n trimmed
    from _ld_candidates
    where _ld_selected=0 and _ld_pruned=0;

    select _ld_candidate_id, _ld_snp_key, _ld_chr_key, _ld_bp_num, _ld_signal
      into :_lead_id trimmed, :_lead_snp trimmed, :_lead_chr trimmed,
           :_lead_bp trimmed, :_lead_signal trimmed
    from _ld_candidates
    where _ld_selected=0 and _ld_pruned=0
    having _ld_candidate_id=min(_ld_candidate_id);
  quit;

  %if %sysevalf(%superq(_remaining_n)=,boolean) %then %let _remaining_n=0;
  %if &_remaining_n=0 or %sysevalf(%superq(_lead_id)=,boolean) %then %goto _ld_finished;

  proc sql noprint;
    select count(*) into :_selected_n trimmed
    from _ld_candidates where _ld_selected=1;
  quit;
  %if %sysevalf(%superq(_selected_n)=,boolean) %then %let _selected_n=0;
  %if %sysevalf(&_max_leads_num > 0) and %sysevalf(&_selected_n >= &_max_leads_num) %then %goto _ld_finished;

  proc sql;
    update _ld_candidates
    set _ld_selected=1,
        _ld_lead_rank=&_selected_n+1
    where _ld_candidate_id=&_lead_id;
  quit;

  data _null_;
    call symputx('_lead_is_rs',prxmatch('/^RS[0-9]+$/i',symget('_lead_snp'))>0,'L');
  run;

  data _ld_lead_edges;
    length query_snp proxy_snp $128 ld_population $16 proxy_r2 8;
    stop;
  run;
  %let _valid_pop_n=0;
  %let _cache_pop_n=0;

  %if &_lead_is_rs %then %do;
    %let _lead_query_snp=%sysfunc(lowcase(%superq(_lead_snp)));
    %let _pop_n=%sysfunc(countw(%superq(ld_pops),%str( )));
    %do _pi=1 %to &_pop_n;
      %let _pop=%scan(%superq(ld_pops),&_pi,%str( ));
      %QueryLD_SNPs_at_Haploreg4(
        snp=&_lead_query_snp,
        LDpop=&_pop,
        ldThresh=&ld_r2_threshold,
        outdsd=_ld_raw_response
      );

      %let _has_rsid=0;
      %let _has_r2=0;
      %if %sysfunc(exist(work._ld_raw_response)) %then %do;
        proc sql noprint;
          select sum(upcase(name)='RSID'), sum(upcase(name)='R2')
            into :_has_rsid trimmed, :_has_r2 trimmed
          from dictionary.columns
          where libname='WORK' and memname='_LD_RAW_RESPONSE';
        quit;
      %end;
      %if %sysevalf(%superq(_has_rsid)=,boolean) %then %let _has_rsid=0;
      %if %sysevalf(%superq(_has_r2)=,boolean) %then %let _has_r2=0;

      %if &_has_rsid>0 and &_has_r2>0 %then %do;
        data _ld_response_norm;
          length query_snp proxy_snp $128 ld_population $16 proxy_r2 8;
          set _ld_raw_response;
          query_snp="&_lead_snp";
          proxy_snp=upcase(strip(vvaluex('rsID')));
          ld_population="%upcase(&_pop)";
          proxy_r2=input(strip(vvaluex('r2')),best32.);
          if not missing(proxy_snp) and not missing(proxy_r2);
          keep query_snp proxy_snp ld_population proxy_r2;
        run;
        proc sql noprint;
          select count(*) into :_response_self_n trimmed
          from _ld_response_norm
          where proxy_snp="&_lead_snp";
        quit;
        %if %sysevalf(%superq(_response_self_n)=,boolean) %then %let _response_self_n=0;
        %if &_response_self_n>0 %then %do;
          %let _valid_pop_n=%eval(&_valid_pop_n+1);
          %if %upcase(%superq(HAPLOREG_LD_QUERY_SOURCE))=LOCAL_CACHE %then
            %let _cache_pop_n=%eval(&_cache_pop_n+1);
          proc append base=_ld_lead_edges data=_ld_response_norm force; run;
        %end;
      %end;
      proc datasets library=work nolist;
        delete _ld_raw_response _ld_response_norm;
      quit;
    %end;
  %end;

  %if &_valid_pop_n>0 %then %do;
    %if &_valid_pop_n=&_requested_pop_n %then %let _lead_query_status=OK;
    %else %let _lead_query_status=PARTIAL;
    %if &_cache_pop_n=&_valid_pop_n %then %let _lead_query_status=&_lead_query_status._LOCAL_CACHE;
    %else %if &_cache_pop_n>0 %then %let _lead_query_status=&_lead_query_status._MIXED;

    proc sql;
      create table _ld_prune_keys as
      select proxy_snp as _ld_snp_key length=128,
             max(proxy_r2) as _edge_r2,
             case
               when count(distinct ld_population)>1 then 'MULTI'
               else min(ld_population)
             end as _edge_population length=32
      from _ld_lead_edges
      where proxy_snp ne "&_lead_snp"
        and proxy_r2 >= &ld_r2_threshold
      group by proxy_snp
      %if &_rule=ALL %then %do;
      having count(distinct ld_population) >= &_requested_pop_n
      %end;
      ;
    quit;

    proc sort data=_ld_candidates; by _ld_snp_key; run;
    proc sort data=_ld_prune_keys; by _ld_snp_key; run;
    data _ld_candidates;
      merge _ld_candidates(in=_candidate) _ld_prune_keys;
      by _ld_snp_key;
      if _candidate;
      if _ld_selected=0 and _ld_pruned=0 and not missing(_edge_r2) then do;
        _ld_pruned=1;
        _ld_pruned_by="&_lead_snp";
        _ld_pruned_lead_rank=&_selected_n+1;
        _ld_prune_r2=_edge_r2;
        _ld_prune_population=_edge_population;
        _ld_independence_method='LD';
      end;
      drop _edge_r2 _edge_population;
    run;
    proc sort data=_ld_candidates; by _ld_candidate_id; run;

    proc sql;
      update _ld_candidates
      set _ld_query_status="&_lead_query_status",
          _ld_independence_method='LD'
      where _ld_candidate_id=&_lead_id;
    quit;
  %end;
  %else %do;
    %if &_failure_action=DISTANCE and %sysevalf(&fallback_dist_bp > 0) %then %do;
      data _ld_candidates;
        set _ld_candidates;
        if _ld_selected=0 and _ld_pruned=0
           and _ld_chr_key="&_lead_chr"
           and _ld_bp_num >= (&_lead_bp-0.5*&fallback_dist_bp)
           and _ld_bp_num <= (&_lead_bp+0.5*&fallback_dist_bp) then do;
          _ld_pruned=1;
          _ld_pruned_by="&_lead_snp";
          _ld_pruned_lead_rank=&_selected_n+1;
          _ld_prune_population='NA';
          _ld_independence_method='DISTANCE_FALLBACK';
        end;
        if _ld_candidate_id=&_lead_id then do;
          _ld_query_status='NO_LD_RESPONSE';
          _ld_independence_method='DISTANCE_FALLBACK';
        end;
      run;
    %end;
    %else %do;
      proc sql;
        update _ld_candidates
        set _ld_query_status='NO_LD_RESPONSE',
            _ld_independence_method='UNRESOLVED_NO_LD'
        where _ld_candidate_id=&_lead_id;
      quit;
    %end;
  %end;

  proc datasets library=work nolist;
    delete _ld_lead_edges _ld_prune_keys;
  quit;
%end;

%_ld_finished:
data &dsdout;
  set _ld_candidates;
  where _ld_selected=1;
  length INDEPENDENCE_METHOD $24 LD_POPULATIONS $64 LD_POPULATION_RULE $8
         LD_QUERY_STATUS $24;
  LD_LEAD_RANK=_ld_lead_rank;
  INDEPENDENCE_METHOD=_ld_independence_method;
  LD_R2_THRESHOLD=&ld_r2_threshold;
  LD_POPULATIONS="%upcase(&ld_pops)";
  LD_POPULATION_RULE="&_rule";
  LD_QUERY_STATUS=_ld_query_status;
  LD_FALLBACK_BP=&fallback_dist_bp;
  drop _ld_:;
run;
proc sort data=&dsdout; by LD_LEAD_RANK; run;

data &audit_out;
  set _ld_candidates;
  length candidate_snp lead_snp $128 selection_action $24
         independence_method $24 query_status $24 ld_population $32;
  candidate_rank=_ld_candidate_id;
  candidate_snp=_ld_snp_key;
  chr=_ld_chr_key;
  bp=_ld_bp_num;
  signal=_ld_signal;
  if _ld_selected then do;
    selection_action='SELECTED_LEAD';
    lead_rank=_ld_lead_rank;
    lead_snp=_ld_snp_key;
  end;
  else if _ld_pruned then do;
    selection_action=ifc(_ld_independence_method='LD','PRUNED_LD','PRUNED_DISTANCE_FALLBACK');
    lead_rank=_ld_pruned_lead_rank;
    lead_snp=_ld_pruned_by;
  end;
  else selection_action='NOT_REACHED';
  prune_r2=_ld_prune_r2;
  ld_population=_ld_prune_population;
  query_status=_ld_query_status;
  independence_method=_ld_independence_method;
  keep candidate_rank candidate_snp chr bp signal selection_action lead_rank
       lead_snp prune_r2 ld_population query_status independence_method;
run;
proc sort data=&audit_out; by candidate_rank; run;

proc sql noprint;
  select count(*) into :TOP_HIT_LD_SELECTED_N trimmed
  from _ld_candidates where _ld_selected=1;
  select count(*) into :TOP_HIT_LD_PRUNED_N trimmed
  from _ld_candidates where _ld_pruned=1;
quit;
%let TOP_HIT_LD_SELECTION_STATUS=COMPLETE;
%put NOTE: LD top-hit selection complete: candidates=&_candidate_n selected=&TOP_HIT_LD_SELECTED_N pruned=&TOP_HIT_LD_PRUNED_N r2=&ld_r2_threshold populations=&ld_pops rule=&_rule.;

%_ld_cleanup:
proc datasets library=work nolist;
  delete _ld_candidates_unsorted _ld_candidates_ranked _ld_candidates
         _ld_lead_edges _ld_prune_keys _ld_raw_response _ld_response_norm;
quit;
%mend;

/* END companion/research/advanced_figures/sources/definitions/get_top_signal_with_ld.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/get_top_signal_within_dist.sas */
%macro get_top_signal_within_dist(
dsdin=,
grp_var=,
signal_var=,
select_smallest_signal=1,
pos_var=,
pos_dist_thrshd=, /*Total exclusion span in bp; the macro keeps one lead signal within +/- 0.5*pos_dist_thrshd*/
dsdout=,
signal_thrshd=1 /*filter the input dsdin by association P, i.e, &signal_var <= &signal_thrshd*/
);

/*
Greedy in-group top-signal selection with a distance exclusion window.

Compared with the older self-join / SQL approach, this version is much faster
when many loci pass the threshold because it:

1. filters candidates first
2. sorts once by group and signal strength
3. keeps selected intervals for the current group only
4. greedily accepts the next best non-overlapping signal

The exclusion window matches the earlier behavior:
  dis_st = pos - pos_dist_thrshd * 0.5
  dis_end = pos + pos_dist_thrshd * 0.5

So a value such as 1e6 means "keep one lead signal per 1 Mb span"
rather than "use a 1 Mb half-window on each side".
*/

data _top_signal_candidates;
length Key $200.;
set &dsdin;
where not missing(&signal_var) and &signal_var > 0 and &signal_var <= &signal_thrshd;
dis_st=&pos_var-&pos_dist_thrshd*0.5;
dis_end=&pos_var+&pos_dist_thrshd*0.5;
Key=catx(':',&grp_var,&pos_var);
run;

%put Warning: duplicate records by Key and &signal_var will be kept for only one record.;
proc sort data=_top_signal_candidates dupout=_dup_records_ out=_top_signal_candidates nodupkeys;
%if &select_smallest_signal=1 %then %do;
  by &grp_var &pos_var &signal_var;
%end;
%else %do;
  by &grp_var &pos_var descending &signal_var;
%end;
run;
%put Warning: duplicate records by Key and &signal_var are saved into the data set _dup_records_.;

proc sort data=_top_signal_candidates;
%if &select_smallest_signal=1 %then %do;
  by &grp_var &signal_var &pos_var;
%end;
%else %do;
  by &grp_var descending &signal_var &pos_var;
%end;
run;

data &dsdout;
  array _sel_dis_st[50000] _temporary_;
  array _sel_dis_end[50000] _temporary_;
  retain _sel_n 0;
  length _keep 8 _i 8;

  set _top_signal_candidates;
  by &grp_var;

  if first.&grp_var then _sel_n = 0;

  _keep = 1;
  do _i = 1 to _sel_n;
    if (&pos_var >= _sel_dis_st[_i]) and (&pos_var <= _sel_dis_end[_i]) then do;
      _keep = 0;
      leave;
    end;
  end;

  if _keep then do;
    output;
    _sel_n + 1;
    if _sel_n > dim(_sel_dis_st) then do;
      put "ERROR: get_top_signal_within_dist exceeded the temporary selection buffer size of 50000.";
      stop;
    end;
    _sel_dis_st[_sel_n] = dis_st;
    _sel_dis_end[_sel_n] = dis_end;
  end;

  drop _sel_n _keep _i;
run;

%if &select_smallest_signal=1 %then %do;
proc sort data=&dsdout;
  by &grp_var &signal_var &pos_var;
run;
%end;
%else %do;
proc sort data=&dsdout;
  by &grp_var descending &signal_var &pos_var;
run;
%end;

proc datasets library=work nolist;
  delete _top_signal_candidates;
quit;

%mend;

/* END companion/research/advanced_figures/sources/definitions/get_top_signal_within_dist.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/iscolallmissing.sas */
%macro iscolallmissing(dsd,colvar,outmacrovar);
%global &outmacrovar;
proc sql noprint;
select nmiss(&colvar)/count(&colvar) 
into: allmissing
from &dsd;
quit;

%if %sysevalf(&allmissing=1,boolean) %then %do;
   %let &outmacrovar=1;
%end;
%else %do;
   %let &outmacrovar=0;
%end;

*This rescues the situation when all data of the column &colvar are missing;
%if &allmissing=. %then %do;
   %let &outmacrovar=1;
 %end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/iscolallmissing.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/make_fake_axis4NegPosVal_by_grps.sas */
%macro make_fake_axis4NegPosVal_by_grps(/*The macro will scale up or down positive or negative values and generate 
yaxis macro labels with the original postive values; To keep using the original positive value but also to scale the ratio
between these positve and negative values, the macro variable NotChangePosVals is set to 1.
The other global macro variable called fake_refline_values, can be used by other procedures to
draw reference lines to separate each group into the final figure if required!
Note: if NotChangePosVals=1, the final negative tick values are scaled values and the macro is updated 
to adjust the axis labels for negative values; since the negative values
are used to draw gene track at the bottom, they will be replaced as " " in the final figure
Note: the output put dsdout contain modified values based on the input scale;
However, the macro variable yaxis_macro_labels is updated to use the original values 
to label axis, although the negative positive values may use different steps in the final axis labels!
*/
dsdin,
axis_var,/*Both negative and positive values of axis var are allowed to use this macro,
           but in each group, only positve (>0) or negative (<0) values are allowed,
           and all 0 axis var values will be excluded from the dsdin, 
           the above of which are the limitations of the macro!*/
axis_grp,
new_fake_axis_var,
dsdout,
yaxis_macro_labels=ylabelsmacro_var,
fc2scale_pos_vals=1, /*Use this fc to enlarge the proportion of positive values in the plots
               It seems that fc=2 is the best for the final ticks of different tracks;*/
NotChangePosVals=1, /*For making manhattan plot, it is better to fix the positive y values,
as scale down the positive values will lead to the y tick labels containing decimals, and
the SAS macro to making local Manhattan plot is set in default to only show integer ticks;
When fc2scale_pos_vals is < 1, the original positive values will be
scaled down to generate fake values; sometimes it is necessary to keep the original values 
but also achieve the goal of scale down these positve values. The workaround method is 
to scale up the negative value with the fold change 1/&fcscale_pos_vals;
Reason for keep the positive values but scale up the negative values:
The coveat for squeezing the positive values by amplifying the value for negative values is that;
the final figure ticks for the positive values will be with very few ticks in the y-axis; 
To rescue this, it is better to multiple both negative and positive values by the same scale value &yscale again;*/
mod_num2keep= /*For the final yaxis_macro_labels, default value for the current var  is empty for not filtering these elements by mod; when values, 
such as 2 or 3 are provided, only keep numbers that fulfil the mod(element,num)=0; 
Note that this will only be applied on numbers that are positve!*/
);

*This para is important for making correct fake axis;
%let axis_step=1;
************************************************************************;
*Get records with negative values in &dsdin;
data &dsdin._neg;
set &dsdin (where=(&axis_var<0));
*temporarily make all negative axis_var as positve ones;
&axis_var=&axis_var*-1;
%if &NotChangePosVals=1 %then %do;
&axis_var=&axis_var/&fc2scale_pos_vals;
%end;
run;

%if %totobsindsd(&dsdin._neg)=0 %then %do;
  %put Warning: there are NO negative values in the dsd &dsdin._neg;
  %abort 255;
%end;

*Make fake_axis for the dsd &dsdin._pos;
%add_fake_pos_by_grp4nonnegvars(
dsdin=&dsdin._neg,
axis_var=&axis_var,
axis_grp=&axis_grp,
new_fake_axis_var=&new_fake_axis_var,
dsdout=&dsdin._neg_fk,
axis_step=&axis_step
);
/*
data &dsdin._neg_fk;
set &dsdin._neg_fk;
%if &NotChangePosVals=1 %then %do;
%end;
%else %do;
&new_fake_axis_var=&new_fake_axis_var*&fc2scale_pos_vals;
%end;
run;
*/

*change back all newly created vars into negative ones;
*including mid_val, tpos, &axis_var, fake&axis_grp, and grp_n;
data &dsdin._neg_fk;set &dsdin._neg_fk;
mid_val=mid_val*-1;grp_n=-1*grp_n;
tpos=tpos*-1;&axis_var=&axis_var*-1;
&new_fake_axis_var=&new_fake_axis_var*-1;
n=n*-1;grpnum=-1*grpnum;
run;

************************************************************************;
*Get records with postive values in &dsdin;
data &dsdin._pos;
*Here would be a potential bug if 0 is the top value in a group with all negative values;
*However, for gene track and scatterplot, this is unlikely happen, as the scatterplot;
*usually has all positive values, including 0;
set &dsdin (where=(&axis_var>=0));
*set &dsdin (where=(&axis_var>0));
*Scale position value and make it larger by fold change;
%if &NotChangePosVals=0 %then %do;
&axis_var=&axis_var*&fc2scale_pos_vals;
%end;
run;

%if %totobsindsd(&dsdin._pos)=0 %then %do;
  %put There are NO positive values in the dsd &dsdin._pos;
  %abort 255;
%end;

*Make fake_axis for the dsd &dsdin._pos;
%add_fake_pos_by_grp4nonnegvars(
dsdin=&dsdin._pos,
axis_var=&axis_var,
axis_grp=&axis_grp,
new_fake_axis_var=&new_fake_axis_var,
dsdout=&dsdin._pos_fk,
axis_step=&axis_step
);

******************Combine fake negative and positve dsds****************;
data &dsdout;
*Note: put the neg dsd first;
set &dsdin._neg_fk &dsdin._pos_fk;
grp_end_tag=tag;
run;

************************************************************************;
*Generate real y axis labels;
%global &yaxis_macro_labels fake_max_y fake_min_y fake_refline_values;

*focus on negative axis values first;
data &dsdin._neg_fk;
set &dsdin._neg_fk;
max_neg=0;
run;
proc sql noprint;
select floor(&axis_var),max_neg
into: min_neg_y4grps separated by " ",
    : max_neg_y4grps separated by " "
from &dsdin._neg_fk
where tag=1
order by n;
proc sql noprint;
select tpos into: fake_refline_values_neg separated by " "
from &dsdin._neg_fk
where tag=1
order by n;
*All max_neg_fale_axis_var will be 0;
*Need to remove the 1st num in fake_refline_values;
%let fake_refline_values_neg=%sysfunc(prxchange(s/^[\-\d\.]+\s*//,-1,&fake_refline_values_neg));

*focus on positive axis values now;
data &dsdin._pos_fk;
set &dsdin._pos_fk;
min_pos=0;
run;
proc sql noprint;
select ceil(&axis_var),tpos,min_pos
into: max_pos_y4grps separated by " ",
    : fake_refline_values_pos separated by " ",
    : min_pos_y4grps separated by " "
from &dsdin._pos_fk
where tag=1
order by n;
*All min_pos_false_axis_var will be 0;
*Need to remove the last num in fake_refline_values;
%let fake_refline_values_pos=%sysfunc(prxchange(s/ [\d\.]+$//,-1,&fake_refline_values_pos));

%let fake_refline_values=&fake_refline_values_neg &fake_refline_values_pos;
%let max_y4grps=&max_neg_y4grps &max_pos_y4grps;
%let min_y4grps=&min_neg_y4grps &min_pos_y4grps;

%put max_y4grps: &max_y4grps;
%put min_y4grps: &min_y4grps;

*Also get the min_val when ll=1;
*Get the macro var fake_max_y value;
data _null_;
set &dsdout end=eof;
if eof then call symputx('fake_max_y',ceil(&new_fake_axis_var));
run;

%let fake_min_y=%scan(&min_y4grps,1,%str( ));
%let fake_min_y=%sysfunc(floor(&fake_min_y));

%let nums=;
*The macro &axis_step will affect the following codes;
*The default step is equal to 1, so there is no adjustment;
*If the step=2, then all _min_y and _end_ need to be minused by 1;

%do xi=1 %to %sysfunc(countw(&max_y4grps));
  *use %str( ) to prevent from lossing of negative nums;
                
	  	%let _min_y=%scan(&min_y4grps,&xi,%str( ));
                %if %sysevalf(&_min_y < 0) %then %do;
                  %let _end_=0;     
                %end;
                %else %do;
                  %let _min_y=%sysevalf(&_min_y+&axis_step,floor);
                  %let _end_=%sysevalf(%scan(&max_y4grps,&xi,%str( ))+&axis_step,ceil);
                %end;
                
                
               /* 
		%if %eval(&_min_y > -1) and %eval(&_min_y < 0)  %then %do;
                  *for negative axis, there is no offset of 1;
                  %let _min_y=%eval(&_min_y-1);
                  %let _end_=%eval(&_end_-1);
		%end;
	      */
		
		%put _min_y is &_min_y;
			
		%if %eval(&xi=1) %then %do;
       %if &NotChangePosVals=0 %then %do;
                  %nums_in_range_adj_scale(st=&_min_y,end=&_end_,by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=&fc2scale_pos_vals,quote=1,mod_num2keep=&mod_num2keep);
        %end;
       %else  %do;/*Scale back the nums when NotChangePosVals is true;*/
                  %nums_in_range_adj_scale(st=&_min_y,end=&_end_,by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=1,quote=1,mod_num2keep=&mod_num2keep);
                  *Need to scale the negative values back to its original values for the axis ticks;
                  %if %sysfunc(prxmatch(/\-/,&&nums&xi)) %then %let nums&xi=%scale_nums_in_list(list=&&nums&xi,factor=%sysevalf(&fc2scale_pos_vals),contain_double_quote=1);
                  *Note: use . to represent single double quote, as SAS will crash if using single quote in prxchange;
                  %let nums&xi=%sysfunc(prxchange(s/[^\-][\-\d]+\.\d+./" "/,-1,&&nums&xi));
                  %put nums&xi are: &&nums&xi;

       %end;        
		 %let nums=&&nums&xi;
     %put &nums;
     %let nums=%sysfunc(prxchange(s/\.\d+//,-1,&nums));
     %put &nums;
		 *Need to replace the last value as empty;
     *Note: the rgx will remove the last tick label that is overlapped with reference line;
     *Let the rgx not match -\d+, such as -1, -2, ..., and other negative numbers;
     *Otherwise, this bug would lead to unmatched quotes in the macro;
      %let nums=%sysfunc(prxchange(s/[^\-](\d+).$/" "/,-1,&nums));
/*      %let nums=%trim(%left(&nums));*/
		%end;
		
    %else %do;
       %if &NotChangePosVals=0 %then %do;
		              %nums_in_range_adj_scale(st=&_min_y,end=&_end_,by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=&fc2scale_pos_vals,quote=1,mod_num2keep=&mod_num2keep);
       %end;
       %else %do;/*Scale back the negative nums when NotChangePosVals is true;*/
		              %nums_in_range_adj_scale(st=&_min_y,end=&_end_,by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=1,quote=1,mod_num2keep=&mod_num2keep);
       %end;

		 *Need to replace the last value as empty;

     %let nums&xi=%sysfunc(prxchange(s/\.0//,-1,&&nums&xi));
     %put Unmodified num&xi are:;
     %put &&nums&xi;
     *Note: the rgx will remove the last element as empty;
     *Note: the rgx will remove the last tick label that is overlapped with reference line;
		 %let new_nums=%qsysfunc(prxchange(s/[^\-](\d+).$/" "/,-1,&&nums&xi));
		 %put modified new_nums are:; 
     %put &new_nums;
		 %let nums=&nums &new_nums;
     *If the value of &nums is too long to be truncated to contain an unmatched quote;

		%end;
		
   %end;

   *Need to remove fake_refline_values in the list of yaxis_macro_labels;
   %do ni=1 %to %ntokens(&fake_refline_values);
           %if &ni=1 %then %do;
               %let _refnum_=%scan(&fake_refline_values,1,%str( ));
           %end;
           %else %do;
               *Note: the fake refline values need to be substracted with the fake refline value before it;
						   %let _refnum_=%sysevalf(%scan(&fake_refline_values,&ni,%str( )) - %scan(&fake_refline_values,&ni-1,%str( )));
            %end;
            %let nums=%sysfunc(prxchange(s/[^\-]&_refnum_\D/" "/,1,&nums));
    %end;
     *Also need to remove the last fake refline value as the top value;
     *Note: the rgx will remove the last tick label that is overlapped with reference line;
     %let nums=%sysfunc(prxchange(s/[^\-](\d+).$/" "/,1,&nums));

	%let &yaxis_macro_labels=&nums;
	%put generated the global macro var &&yaxis_macro_labels for labeling y axis, which are: &&&yaxis_macro_labels;
		%put generated the global macro var fake_min_y, the value of which are all 0s;
	 %put generated the global macro var fake_max_y, the value of which is &fake_max_y;
		%put generated the global macro var fake_refline_values, the value of which can be used to make reflines to separate grps:;
		%put &fake_refline_values;
/*    %abort 255;*/

%mend;

/* END companion/research/advanced_figures/sources/definitions/make_fake_axis4NegPosVal_by_grps.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/make_fake_axis_values4grps.sas */
%macro make_fake_axis_values4grps(
/*This macro has issue when axis_var containing positve and negative values among different grps*/
dsdin,
axis_var,
axis_grp,
new_fake_axis_var,
dsdout,
yaxis_macro_labels=ylabelsmacro_var,
step4yaxis_macro_labels=1,/*Only keep ticks with mod(t,step)=0, which will prevent the y-axis ticks from too compacted with each other!*/
fc2scale_pos_vals=2, /*Use this fc to enlarge the proportion of positive values in the plots
It seems that fc=2 is the best for the final ticks of different tracks;
*/
mod_num2keep= /*Default is empty for not filtering these elements by mod; when values, 
such as 2 or 3 are provided, only keep numbers that fulfil the mod(element,num)=0*/
);

*Fix a bug when only one record in a group;
*make an extra copy for the records to make it has >1 records;
*This is because the script will not be able to update corrected;
*y axis labels if there is only one record for a group;
proc sql;
create table _single_ as 
select *
from &dsdin
group by &axis_grp
having count(&axis_grp)=1;
data &dsdin;
set &dsdin _single_;
data &dsdin;
set &dsdin;
*Scale position value and make it larger by fold change;
if &axis_var>0 then &axis_var=&fc2scale_pos_vals*&axis_var;
run;

*add 2 to the max value to make grps separated better;
proc sql;
create table &dsdout as
select a.*,&axis_var as &new_fake_axis_var,
       floor(min(&axis_var)) as min_val,
       ceil(max(&axis_var))+2 as max_val
from &dsdin as a
group by &axis_grp
order by &axis_grp,&axis_var;

data &dsdout;
retain max grpnum mtag 0;
set &dsdout;
grp_end_tag=0;
if first.&axis_grp then do;
*important to set max^=0;
*No other value can be used, as 0 is very special;
 if max^=0 then do;
/*	 if min_val<0 then do;*/
/*		 *The 1st one of each grp would be the min_val;*/
/*   &new_fake_axis_var=max-min_val;*/
/*		end;*/
/*		else do;*/
/*   &new_fake_axis_var=&axis_var+max;*/
/*		end;*/
	  *As max value is integer, the 1st y value if not integer, need to add back its decimal value;
	  &new_fake_axis_var=max+(&axis_var-min_val);
   grpnum=grpnum+1;
 end;
 else do;
  &new_fake_axis_var=&axis_var;
		mtag=1;
  grpnum=1;
 end;
end;

else if last.&axis_grp then do;
 grp_end_tag=1;
	*important to set max^=0;
	*also need to check mtag,which forces to run the following when passed the;
	*the 1st element;
 if max^=0 then do;
   &new_fake_axis_var=(&axis_var-min_val)+max;
/*		*for negative min_val, it is necessary to adjust max;*/
/*		if min_val<0 then do;*/
/*		  *when max is still equal to 0, keep it as 0;*/
/*		  if max^=0 then do;*/
/*     max=max+max_val-min_val;*/
/*					*Important to make it as the close largest integer;*/
/*					max=ceil(max);*/
/*				end;*/
/*		end;*/
/*		else do;*/
/*			 *max=max+max_val;*/
/*		  *The above can not be used;*/
/*		  *Not 100% sure why the following works!;*/
/*		   max=&axis_var-min_val+2+max;*/
/*					max=ceil(max);*/
/*		end;*/
			 *Use correct syntax;
			 max=ceil(&new_fake_axis_var)+2;
 end;
 else do;
  &new_fake_axis_var=&axis_var;
		*for negative min_val, it is necessary to adjust max;
		*Only if max^=0, the value of max will be updated;
		if min_val<0 and max^=0 then do;
   max=max+max_val-min_val;
			max=ceil(max);
		end;
		else do;
			max=max+max_val;
			max=ceil(max);
		end;
 end;
	mtag=0;
end;

else do;
  if min_val<0 then do;
     &new_fake_axis_var=&axis_var-min_val+max;
		end;
		else do;
		  *this is wrong;
/*				&new_fake_axis_var=&axis_var+max;*/
	  	&new_fake_axis_var=&axis_var-min_val+max;
		end;																																																	                                                                                                                                                           
		if max=0 and mtag=1 then &new_fake_axis_var=&axis_var;
end;
output;
*drop min max min_val max_val;
*Make sure to sort by two vars;
by &axis_grp &axis_var;
run;

*Generate real y axis labels;
%global &yaxis_macro_labels fake_max_y fake_min_y fake_refline_values;
proc sql noprint;
select max_val,min_val,max-1 
into: max_y4grps separated by " ",
    : min_y4grps separated by " ",
				: fake_refline_values separated by " "
from &dsdout
where grp_end_tag=1
order by grpnum,&axis_var;

%put max_y4grps: &max_y4grps;
%put min_y4grps: &min_y4grps;

*Also get the min_val when grp_end_tag=1;
*Get the macro var fake_max_y value;
data _null_;
set &dsdout end=eof;
if eof then call symputx('fake_max_y',ceil(&new_fake_axis_var));
run;

%let fake_min_y=%scan(&min_y4grps,1,%str( ));
%let fake_min_y=%sysfunc(floor(&fake_min_y));

%let nums=;
%do xi=1 %to %sysfunc(countw(&max_y4grps));
  *use %str( ) to prevent from lossing of negative nums;
		%let _min_y=%scan(&min_y4grps,&xi,%str( ));
		%put _min_y is &_min_y;
		%if %eval(&xi=1) %then %do;
   /* %nums_in_range(st=&_min_y,end=%eval(%scan(&max_y4grps,&xi,%str( ))-1),by=1,outmacrovar=nums&xi,quote=1);*/
    %nums_in_range_adj_scale(st=&_min_y,end=%eval(%scan(&max_y4grps,&xi,%str( ))-1),by=1,outmacrovar=nums&xi,
                   filter4scaledvals=%str(>0),scale=&fc2scale_pos_vals,quote=1,mod_num2keep=&mod_num2keep);
				%let nums=&&nums&xi;
				*Need to replace the last value as empty;
   %let nums=%sysfunc(prxchange(s/\S+$/" "/,-1,&nums));
		%end;
		%else %do;
/*		  %nums_in_range(st=&_min_y,end=%eval(%scan(&max_y4grps,&xi,%str( ))-1),by=1,outmacrovar=nums&xi,quote=1); */
		  %nums_in_range_adj_scale(st=&_min_y,end=%eval(%scan(&max_y4grps,&xi,%str( ))-1),by=1,outmacrovar=nums&xi,
                                 filter4scaledvals=%str(>0),scale=&fc2scale_pos_vals,quote=1,mod_num2keep=&mod_num2keep);
				*Need to replace the last value as empty;
				%let new_nums=%sysfunc(prxchange(s/\S+$/" "/,-1,&&nums&xi));
				%put modified new_nums are: &new_nums;
				%let nums=&nums &new_nums;
		%end;
	%end;
	%let &yaxis_macro_labels=&nums;
	%put generated the global macro var &&yaxis_macro_labels for labeling y axis, which are: &&&yaxis_macro_labels;
		%put generated the global macro var fake_min_y, the value of which is &fake_min_y;
	 %put generated the global macro var fake_max_y, the value of which is &fake_max_y;
		%put generated the global macro var fake_refline_values, the value of which can be used to make reflines to separate grps:;
		%put &fake_refline_values;
%mend;

/* END companion/research/advanced_figures/sources/definitions/make_fake_axis_values4grps.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/map_grp_assoc2gene4covidsexgwas.sas */
%macro map_grp_assoc2gene4covidsexgwas(
/*Note: this macro uses a internal macro Multgscatter_with_gene_exons
Also, the macro will only focus on protein coding genes and its exons as demonstrated 
at lines 125 in the macro as follows:
type in ("gene" "exon") and protein_coding=1
It is possible to focus on transcript and its exons by updating the above code;
*/
focus_on_transcript=1,/*This will generate a subset exon GTF data set by 
replacing gene variable with ensembl transcript variable and removing rows 
with the type of "gene" and update transcript as "gene" to enable the macro
to work on these transcripts instead of genes*/
gwas_dsd=FM.f_vs_m_mixedpop,/*Requires to have the arbitary var 
chr in the input gwas dsd*/
gtf_dsd=FM.GTF_HG19,/*Need to use sas macro import gtf to save GTF_HG19;
these vars are arbitrary, such as chr, st, end, protein_coding (1 or 0)
and type of bed region (gene or exon);*/
chr=,
min_st=,
max_end=,
dist2genes=100000,
AssocPVars=pval gwas1_p gwas2_p,
ZscoreVars=diff_zscore gwas1_z gwas2_z,
design_width=800,/*Width*height=800*800 would be the best for publication*/
design_height=800,
image_dpi=300,
barthickness=8,
dotsize=6,
grp_font_size=8,/*font size for gene labels in the bottom gene track*/
/*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=circlefilled,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=%str(thickness=6 color=darkorange pattern=solid),/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
dist2sep_genes=0.3, /*
this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 to plot ALL genes in the same line;
(2) give value between 0 and 1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track!
*/
where_cndtn_for_gwasdsd=%str() /*add filters to the input gwas_dsd; such as pval < 0.05 or gwas1_p < 0.05 or gwas2_p < 0.05*/,

shift_text_yval=-0.2, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
fig_fmt=svg, /*output figure formats: svg, png, jpg, and others*/
pct4neg_y=2, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
adjval4header=-0.5, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/

gwas_pos_var=pos,
Variant_Length_Var=,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=&Pos_Var-0.5*&Variant_Length_Var and end=&Pos_Var-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
*/
gwas_labels_in_order=gwas1_vs_gwas2 gwas1 gwas2, /*Provide gwas names matched with the numeric scatter_grp_var
Use _ to represent blank space in each name, and these _ will be changed back into blank space!*/
makedotheatmap=0,/*use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=%nrbquote(&lattice_subgrp_var),/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=darkgreen lightgreen deepskyblue,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=gold mediumred vipk,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=-8,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=8,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/

color_resp_var=,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=cyan blue, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=%str(darkblue darkgreen darkred darkyellow 
CXFFF000 CXFF7F00 CXFF00FF CXFF0000 CXEAADEA CXE6E8FA CXDB9370 CXDB70DB CXD9D919 CXD8D8BF 
CXCD7F32 CXC0C0C0 CXBC8F8F CXB87333 CXB5A642 CXADEAEA CXA67D3D CXA62A2A CX9F9F5F CX9F5F9F 
CX97694F CX8E236B CX8E2323 CX8C7853 CX8C1717 CX871F78 CX856363 CX855E42 CX70DB93 CX5F9F9F 
CX5C4033 CX545454 CX4F2F4F CX4E2F2F CX32CD32 CX2F4F2F CX238E23 CX236B8E CX23238E CX00FFFF 
CX00FF00 CX0000FF CX000000
),
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/

makeheatmapdotintooneline=0,/*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
var4label_scatterplot_dots=, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
var4mark_ld_scatterplot_dots=, /*Optional character variable containing '*' for LD-linked variants.*/
ld_marker_color=black,
ld_marker_legend_symbol=*,
ld_heatmap_var=,
ld_heatmap_colormodel=CXF7FBFF CX6BAED6 CX54278F,
ld_heatmap_legend_title=%str(LD r2),
text_rotate_angle=90, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=,
font_size4textlabels=10,
label_headroom_frac=,
label_center_offset=,
auto_rotate2zero=0, /*supply value 1 when less than 3 text labels, it is good to automatically set the text_rotate_angel=0*/
pct2adj4dencluster=0.15,/*For SNP labels on the top, please try to use this parameter, which only works when 
there are less than or equal to 3 top SNPs if track_width <= 500, or 5 top SNPs if track_width between 500 and 800, or 6 top SNPs if 
track_width >=800, otherwise, this parameter will be excluded and even step will be used to separate them on the top!
and SNPs within a cluster are overlapped with each other or overlapped with elements from other SNP cluster, so it is feasible to 
avoid this issue by increasing the pct or reducing it, respectively*/
yoffset4max_drawmarkersontop=0.25, /*If draw scatterplot marker labels on the top of track, 
 this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=3.5, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=%str(-log10%(P%)),/*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=%str(Z score),/*Visible title for the continuous colorbar when heatmap coloring is enabled*/
plot_title=,/*Optional visible title naming the color metric.*/
adj_spaces_among_top_snps=1 /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
);
%if %ntokens(&gwas_labels_in_order)^=%ntokens(&AssocPVars) %then %do;
  %put Please ensure the gwas_labels_in_order has the same number of elements as that of AssocPVars;
  %put gwas_labels_in_order=;
  %put AssocPVars=;
  %abort 255;
%end;

%let orig_minst=&min_st;
%let orig_maxend=&max_end;

%let min_st=%sysevalf(&min_st-&dist2genes);
%let max_end=%sysevalf(&max_end+&dist2genes);

*if the dist between min_st and max_end, the range may not be;
*able to cover the gene body, resulting in failure of drawing gene body and exons;
%if %sysevalf(&max_end - &min_st)<1e8 %then %do;
 %put Extend to the st and end position to cover gene bodies and exons;
 %let min_st=%sysevalf(&min_st - 50000000);
 %let max_end=%sysevalf(&max_end + 50000000);
%end;


%let totP=%sysfunc(countw(&AssocPVars));
%if &totP ne %sysfunc(countw(&ZscoreVars)) %then %do;
    %put Please make sure the two macro vars have the same number of parameters:;
    %put Your AssocPVars: &AssocPVars;
    %put Your ZscoreVars: &ZscoreVars;
    %abort 255;
%end;

%if &focus_on_transcript=0 %then %do;
*Need to first select these genes and get their min_pos and max_pos;
*then use these regions to lookup with associaiton signals;
data exons(keep=_chr_ st end grp pi type &Variant_Length_Var);
length _chr_ $5.;
*Enlarge the length of grp, which may be truncated if too short!;
length grp $30.;
set &gtf_dsd;
pi=0;
grp=genesymbol;
_chr_=cats("chr",put(chr,2.));
where chr=&chr and 
( (st between &min_st and &max_end) or (end between &min_st and &max_end) )
and 
/* type="gene" and protein_coding=1; */
/*This does not work as expected, as some exons belonging to the same gene are colored differently*/
/*It is also very time-consuming*/
/* type in ("exon" "gene") and protein_coding=1; */
type in ("gene" "exon") and protein_coding=1 and genesymbol not contains '.';
/*and genesymbol not contains 'ENSG';*/
run;
/* %abort 255; */
%end;
%else %do;
*Need to first select these transcripts of genes and get their min_pos and max_pos;
*then use these regions to lookup with associaiton signals;
data exons(keep=_chr_ st end grp pi type &Variant_Length_Var);
length _chr_ $5.;
*Enlarge the length of grp, which may be truncated if too short!;
length grp $50.;
set &gtf_dsd;
pi=0;
*Note that transcript variable ensembl_transcript is used to replace gene variable;
grp=ensembl_transcript;
_chr_=cats("chr",put(chr,2.));
where chr=&chr and 
( (st between &min_st and &max_end) or (end between &min_st and &max_end) )
and 
/* type="gene" and protein_coding=1; */
/*This does not work as expected, as some exons belonging to the same gene are colored differently*/
/*It is also very time-consuming*/
/* type in ("exon" "gene") and protein_coding=1; */
type in ("transcript" "exon") and protein_coding=1 and genesymbol not contains '.';
/*and genesymbol not contains 'ENSG';*/
run;

*Need to update the type of transcript as gene to draw each transcript as that of a gene in the final track of scatter plots;
data exons;
set exons;
if type="transcript" then type="gene";
run;
/* %abort 255; */
%end;


*Important to remove dup exons;
proc sort data=exons nodupkeys;by _all_;run;

*Count how many exons in the exons dsd;
*If there are more than 1000, keep only gene and exclude all exons;
proc sql noprint;
select count(type) into: tot_exons
from exons
where type="exon";
%put There are &tot_exons unique exons!;
%if &tot_exons > 20000 %then %do;
%put There are too many exons in the input dataset, with n=%left(&tot_exons)!;
%put The macro will exclude these exons;
/*%abort 255;*/
data exons;
set exons;
where type^="exon";
run;
%end;


*Need to drop the var type;
data exons;
set exons(drop=type);
run;
proc sql noprint;
select count(*) into: tot_bed_regs
from exons;
%if &tot_bed_regs > 20000 %then %do;
  %put Too many bed regions in your exon dsd;
		%put Only < 20000 bed regions can be fastly draw by the macro;
		%abort 255;
%end;

*Need to extend the min_st and max_end for better visualization in the final figure;
proc sql noprint;
select min(st)-1000-&dist2genes, max(end)+1000+&dist2genes 
into :min_gpos,:max_gpos
from exons;
*Need to compare it with original input min_st and max_end;
/* Large positions can be formatted as 6.601E7 or 1.1708E8.  A plain
   macro %IF may compare those strings lexically and clip away the lead SNP. */
%if %sysevalf(&max_end>&max_gpos,boolean) %then %let max_gpos=&max_end;
%if %sysevalf(&min_st<&min_gpos,boolean) %then %let min_gpos=&min_st;
%if %sysevalf(&min_gpos<0,boolean) %then %let min_gpos=0;
%put The final chromosomal range for your query region is from &min_gpos to &max_gpos;
%put However, we will restrict the x-axis to the original min and max genomic position in the final figure;
*Need to enlarge the grp length by asigning longer comman label for it;
*Filter input gwas_dsd with where condition to reduce the total number of markers;
*Assign enough length for the variable grp, which will be further combined with gene names later;
*Larger length will avoid of truncating of gene names;
proc sql;
create table signal_dsd as
select 
     %if %length(&color_resp_var)>0 %then %do;
       &color_resp_var,
     %end;
     %if %length(&var4label_scatterplot_dots)>0 %then %do;
       &var4label_scatterplot_dots,
     %end;
     %if %length(&var4mark_ld_scatterplot_dots)>0 %then %do;
       &var4mark_ld_scatterplot_dots,
     %end;
     %if %length(&Variant_Length_Var)>0 %then %do;
       &Variant_Length_Var,
     %end;
 
     %do i=1 %to &totP;
	    %if &makedotheatmap=1 %then %do;
		%*Use original ZscoreVars for making heatmap later;
		%scan(&ZscoreVars,&i) as AssocGrp&i,
		%end;
		%else %do;
		%*use binary variable to color scatter plot dots when not in heatmap style;
		%*Pos=1 and Neg=0;
        %scan(&ZscoreVars,&i) > 0 as AssocGrp&i,
		%end;
       -log10(%scan(&AssocPVars,&i)) as var4log10P&i,
     %end;
       &gwas_pos_var as st,&gwas_pos_var+1 as end,"GWAS_Assoc_Signal" as grp length=50,
       cats("chr",put(chr,2.)) as _chr_
from &gwas_dsd	
%if %length(&where_cndtn_for_gwasdsd)^=0 %then %do;
(where=(&where_cndtn_for_gwasdsd))
%end;
where chr=&chr and 
(&gwas_pos_var between &min_gpos and &max_gpos);
/*%abort 255;*/

/* The region will be different from the (pos between &minst and &maxend); */

*For debug only;
/*data a;*/
/*set &gwas_dsd;*/
/*run;*/
/*%abort 255;*/

data signal_dsd(where=(var4log10P>0));
*The final output would be necessary with p<0.05;
set signal_dsd;
array X{*} var4log10P1-var4log10P&totP;
array Z{*} AssocGrp1-AssocGrp&totP;
*array W{*} _AssocGrp1-_AssocGrp&totP; *No need anymore;
do pi=1 to dim(X);
   var4log10P=X{pi};
   AssocGrp=Z{pi};
   *_AssocGrp=W{pi};*No need anymore;
   output;
end;
run;
/*%abort 255;*/

data signal_dsd(rename=(_chr_=chr));
set signal_dsd;
if _chr_="chr23" then _chr_="chrX";
data exons(rename=(_chr_=chr));
set exons;
if _chr_="chr23" then _chr_="chrX";
run;
/*%abort 255;*/
*Make sure the two datasets have 4 comman vars, including chr, st, end, and grp;
*Need to ensure the dist2st_and_end as 0 to make the final scatterplot and gene track matching perfectly.;
%Multgscatter_with_gene_exons(
bed_dsd=signal_dsd,
Variant_Length_Var=&Variant_Length_Var,/*this variable if not empty, its value will be used to extend the value of Pos_Var for making 
the start and end position for SNP_Var, i.e., st=&Pos_Var-0.5*&Variant_Length_Var and end=&Pos_Var-0.5*&Variant_Length_Var;
This would be especially helpful for mixing CNV and SNV data for making scatter plots, as it is only necessary
to provide middle position for CNVs and its lengths for ploting CNVs and SNVs together!
*/
yval_var=var4log10P,
scatter_grp_var=pi,
lattice_subgrp_var=AssocGrp,  /*When &makedotheatmap=0, use AssocGrp to color scatterplot by its direction, i.e., negative and position,
when &makedotheatmap=1, also use AssocGrp to make heatmap for the scatter plot in quantitative way, as the input variable AssocGrp is 
also modified based on the input parameter &makedotheatmap!*/
gene_exon_bed_dsd=exons,/*Too many exons will slow down the macro dramatically*/
dist2st_and_end=0,
design_width=&design_width,
design_height=&design_height,
image_dpi=&image_dpi,
barthickness=&barthickness,
dotsize=&dotsize,
grp_font_size=&grp_font_size,
/*Important parameters for drawing SNVs and CNVs together*/
scattermarker_symbol=&scattermarker_symbol,/*Assign specific marker symbol, such as ibeam, circlefilled, circle, dot, squarefilled, or square, for scatter plot;
Note the size of the designated marker symbol will be defined by the macro variable dotsize; when creating heatmap, you can assign
squarefilled to the scattermarker_symbol, which would be more compatable with the highlow line style in for CNV or bed regions!*/ 
highlow_line_cmd=&highlow_line_cmd,/*For CNV bed regions, customize the following parameters using dot, dash, or solid line pattern 
with custome thickness and color for the line; please increase the thickness to match with that of 
dotsize=10 when scattermarker_symbol=squarefilled for the scatter plot, which will enable the square and the line
in the same size and color*/
min_dist4genes_in_same_grps=&dist2sep_genes, /*
this will ensure these genes close to each other to 
be separated in the final gene track; 
(1) give 0 to plot ALL genes in the same line;
(2) give value between 0 and 1 to separate genes based on the pct distance to the whole region;
(3) give value > 1 to use absolute distance to separate genes into different groups;
Customize this for different gene exon track!*/
sc_labels_in_order=&gwas_labels_in_order, /*Provide scatter names matched with the numeric scatter_grp_var*/
min_xaxis=&orig_minst,
max_xaxis=&orig_maxend,
yoffset4max_drawmarkersontop=&yoffset4max_drawmarkersontop,/*If draw scatterplot marker labels on the top of track, 
this fixed value will be used instead of yaxis_offset4max!*/
Yoffset4textlabels=&Yoffset4textlabels, /*Move up the text labels for target SNPs in specific fold; 
the default value 2.5 fold works for most cases*/
scatter_yaxis_label=&scatter_yaxis_label, /*Visible y-axis title for the stacked association tracks*/
heatmap_legend_title=&heatmap_legend_title, /*Visible title for the continuous colorbar when heatmap coloring is enabled*/
plot_title=&plot_title,
shift_text_yval=&shift_text_yval, /*in terms of gene track labels, add positive or negative vale, ranging from 0 to 1, 
                      to liftup or lower text labels on the y axis; the default value is -0.2 to put gene lable under gene tracks;
                      Change it with the macro var pct4neg_y!*/
fig_fmt=&fig_fmt, /*output figure formats: svg, png, jpg, and others*/
pct4neg_y=&pct4neg_y, /*the most often used value is 1;
              compacting the bed track y values by increasing the scatterplot scale, 
              which can reduce the bed trace spaces; It seems that two-fold increasement
              leads to better ticks for different tracks!
              Use value >1 will increase the gene tract, while value < 1 will reduce it!
              Note: when there are only 1 or 2 scatterplots, it is better to provide value = 0.5;
              Modify this parameter with the parameter shift_text_yval to adjust gene label!
              Typically, when there are more scatterplots, it is necessary to increase the value of pct4neg_y accordingly;
              If there are only <4 scatterplots, the value would be usually set as 1 or 2;
              */
adjval4header=&adjval4header, /*In terms of header of each subscatterplot, provide postive value to move up scatter group header by the input value*/

makedotheatmap=&makedotheatmap,/*Use the default value 0 of &makedotheatmap to draw scatter plot in two color modes;
Assign value 1 to it to use colormap to draw dots in scatterplot instead of the discretemap;
Note: if makedotheatmap=1, the scatterplot will not use the discretemap mode based on
the negative and postive values of lattice_subgrp_var to color dots in scatterplot*/

/*Main color scheme for coloring dots in scatter plot with your quantitative color response variable
Note: it is necessary to have makedotheatmap=1 and use the default heatmap_var or other quantitative
variable with both negative and positive values to color the scatter plot; when the quantitative response
variable is postive or negative, please change the heatmap_min_neg_val as 0 for postive values, meanwhile,
for all negative values, please assign value 0 to heatmap_max_pos_val*/
heatmap_var=&heatmap_var,/*Assign lattice_subgrp_var to this macro var to draw scatter plot in heatmap
using lattice_subgrp_var with rangeattrmap instead of drawing dots using binary mode, such as 0 and 1 representing Pos
and negative directions of latticen_subgrp_var!*/
heatmap_Neg_rangealtcolormodel=&heatmap_Neg_rangealtcolormodel,/*Range alt color model for negative values, heatmap_var<=0,  in heatmap*/
heatmap_Pos_rangealtcolormodel=&heatmap_Pos_rangealtcolormodel,/*Range alt color model for positve values, heatmap_var>=0, in heatmap*/
heatmap_min_neg_val=&heatmap_min_neg_val,/*Minimum negative value for the heatmap_var when it is not empty; 
change this to customize the minimum value for colorbar in heatmap*/
heatmap_max_pos_val=&heatmap_max_pos_val,/*Maximum postive value for the heatmap_var when it is not empty; 
change this to customize the max value for colorbar in heatmap*/

/*Alternative color scheme for categorical color response variable! Please keep it in default
value if you don't want to use it for your quantitative color response variable*/
color_resp_var=&color_resp_var,/*Use the variable to draw colormap of dots in scatterplots with colors
supplied by a later macro variable dataContrastCols that are specifically designated for 
scatterplot dots but not other tracks under the scatter plots, such as gene tracks;.
previously if the macro var is empty, the default var would be the same as that of yval_var;
Later it is updated to enable the macro to use lattice_subgrp_var but not yval_var when 
this color_resp_var is empty! A later macro variable dataContrastCols will be used 
to supply colors for different groups of the variable solely for coloring scatterplot dots!*/
fixedcols4tracksunderscatter=&fixedcols4tracksunderscatter, /*when color_resp_var is not empty, all tracks under scatterplots will be fixed with 
two different colors, including cyan and blue, represented by the macro var fixedcols4tracksunderscatter!*/
color_resp_grpdsd=&color_resp_grpdsd,/*this dataset contains two columns, including &color_resp_var and the fixed
variable numgrp4color_resp,which are corresponding to the unique char color_resp_var and 
its associated numeric var that would be sorted to order these char color_resp_var in the final figure legend!
Note: for color_resp_var not included in the dataset, they will be asigned as Others;
Custom colors with the same number of unique color_resp_var for these groups can be provided to 
a latter macro variable dataContrastCols*/
dataContrastCols=&dataContrastCols,
/*Note: these colors will be used for the scatterplot and gene track together when color_resp_var is a char var, so it is difficult control*/
makeheatmapdotintooneline=&makeheatmapdotintooneline, /*This will make all dots have the same yaxis value but have different colors 
based on its real value in the heatmap plot; To keep the original dot y axis value, assign 0 to the macro var
This would be handy when there are multiple subgrps represented by different y-axis values! By modifying
the y-axis values for these subgrps, the macro can plot them separately in each subtrack!
*/
text_rotate_angle=&text_rotate_angle, /*Angle to rotate text labels for these selected dots by users*/
label_position_overrides=&label_position_overrides,
font_size4textlabels=&font_size4textlabels,
label_headroom_frac=&label_headroom_frac,
label_center_offset=&label_center_offset,
auto_rotate2zero=&auto_rotate2zero, /*supply value 1 when less than 3 text labels, it is good to automatically set the text_rotate_angel=0*/
pct2adj4dencluster=&pct2adj4dencluster,
var4label_scatterplot_dots=&var4label_scatterplot_dots, /*Make sure the variable name is not grp, which is a fixed var used by the macro for other purpose;
Whenever  makeheatmapdotintooneline=1 or 0, it is possible to use values of the var4label_scatterplot_dots to
label specific scatterplot dots based on the customization of the variable predifined by users for the input data set; 
default is empty; provide a variable that include non-empty strings for specific dots in the 
scatterplots;*/
var4mark_ld_scatterplot_dots=&var4mark_ld_scatterplot_dots,
ld_marker_color=&ld_marker_color,
ld_marker_legend_symbol=&ld_marker_legend_symbol,
ld_heatmap_var=&ld_heatmap_var,
ld_heatmap_colormodel=&ld_heatmap_colormodel,
ld_heatmap_legend_title=&ld_heatmap_legend_title,
adj_spaces_among_top_snps=&adj_spaces_among_top_snps /*Provide value 1 to adjust spaces among top SNP labels; otherwise, give value 0 to not 
adjust top SNPs labels if these labels are rotated 90 degree, which is helpful when the space adjusted labels are not pretty*/ 
);
%mend;

/* END companion/research/advanced_figures/sources/definitions/map_grp_assoc2gene4covidsexgwas.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/mkfmt4grps_by_var.sas */
%macro mkfmt4grps_by_var(
grpdsd,
grp_var,
by_var,/*Empty value is possible for this var, which is handy 
when there would be duplciates of grp_var after sorting by 
grp_var and by_var for the by_var to make a new format*/
outfmt4numgrps,
outfmt4chargrps,
dsd4fmt=dsd4fmt, /*This dataset can be used to get fmt info*/
numstarter=1 /*This will restrict the starter as 1 or other supplied number;
such as 0, which would be helpful when it is necessary to use different range
for making the format*/
);
%local rnd;

proc sort data=&grpdsd(keep=&grp_var &by_var) nodupkeys out=grpdsd;
*Make sure to sort it first by &by_var, and then by &grp_var;
*This was wrong, as some grps will be excluded by nodupkeys sorting with &by_var first;
by &grp_var &by_var;
run;

proc sql noprint;
select max(ndup_grps) into: maxdups
from 
(select count(*) as ndup_grps
from grpdsd
group by &grp_var)
;

%if &maxdups >1 %then %do;
		   %put Please evaluate the data set grpdsd for the combination between two vars, including &grp_var and &by_var;
		   %put It is necessary to have no duplicates in the first grp_var: &grp_var;
		   %put Currently there are duplicates for grp_var &grp_var after running proc sort nodupkeys by the two vars;
		   %put You may try to replace the two vars by using grp_var and grp_var, which means to use grp_var to replace the by_var;
		   %abort 255;
%end;

*The above dataset may still contains duplicates of &grp_var;
*Need to keep all unique &by_var and &grp_var;
/* proc sort data=grpdsd nodupkeys;by &grp_var; */
/* proc sort data=grpdsd;by &by_var &grp_var; */
/* run; */

*Need to sort grps by the by_var for making formats;
*Only when the by_var is not empty, run this codes;
%if %length(&by_var)>0 %then %do;
proc sort data=grpdsd;by &by_var;run;
%end;

/* Use a timestamp-derived suffix so this helper does not depend on
   a separately compiled random-number macro. */
%let rnd=%sysfunc(floor(%sysfunc(datetime())));
%let rnd=&rnd._;
data fmt4numgrps&rnd;
set grpdsd;
fmtname = "&outfmt4numgrps";
type = "I";
label = _N_ +  &numstarter - 1;
rename &grp_var = start;
run;
proc format cntlin=fmt4numgrps&rnd;
run;
quit;
data fmt4chargrps&rnd;
set grpdsd(drop=&by_var);
*Do not use &by_var here to asign group specific order for start;
*This will be a bug when there are duplicates in the &by_var;
/* by &by_var; */
start = _N_ + &numstarter - 1;
rename &grp_var=label;
fmtname = "&outfmt4chargrps";
type = "n";
run;
proc format cntlin=fmt4chargrps&rnd;
run;
%if %length(&dsd4fmt)>0 %then %do;
data &dsd4fmt;
set fmt4chargrps&rnd;
run;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/mkfmt4grps_by_var.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/ntokens.sas */
%macro ntokens(list);
    %if %length(%superq(list))=0 %then 0;
    %else %eval(1 + %length(%sysfunc(compbl(&list))) - %length(%sysfunc(compress(&list))));
%mend ntokens;

/* END companion/research/advanced_figures/sources/definitions/ntokens.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/numargs.sas */
%macro numargs(arg);
   %if &arg= %then %do;
        0
      %end;
    %else %do;
       %let n=1;
       %do %until (%qscan(&arg,%eval(&n),%str( ))=%str()); 
         %let n=%eval(&n+1);
       %end;
       %eval(&n-1)
    %end;
%mend numargs;

/* END companion/research/advanced_figures/sources/definitions/numargs.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/number_rows_by_grp.sas */
%macro number_rows_by_grp(
dsdin,
grp_var,
num_var4sort,
descending_or_not,
dsdout
);

%if &descending_or_not %then %do;
proc sort data=&dsdin;
key &grp_var &num_var4sort/ descending;
run;
%end;
%else %do;
proc sort data=&dsdin;
key &grp_var &num_var4sort;
run;
%end;

proc sort data=&dsdin;by &grp_var;
run;

data &dsdout;
retain ord 0;
set &dsdin;
if first.&grp_var then do;
 ord=1;output;
end;
else if not last.&grp_var then do;
 ord=ord+1;output;
end;
else if last.&grp_var then do;
 ord=ord+1;output;
 ord=0;
end;
by &grp_var;
run;

%if &descending_or_not %then %do;
proc sort data=&dsdout;
key &grp_var &num_var4sort / descending;
run;
%end;
%else %do;
proc sort data=&dsdout;
by &grp_var &num_var4sort;
run;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/number_rows_by_grp.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/nums_in_range_adj_scale.sas */
%macro nums_in_range_adj_scale(
/*Note: the scale can only be integer with value >=1, as the macro will only be able to scale down the numbers in range!*/
st,/*start value that can be negative and position*/
end,/*end value*/
by,/*by value for each step; make sure it is matchable with st and end values*/
outmacrovar,/*created a global macro var containing linked nums by space for later access*/
filter4scaledvals=%str(>0),/*Only apply the scaling to specific numbers met the filter*/
scale=2,/*integer num to scale down the nums, i.e., num/scale, that will be in the final macro var*/
quote=1, /*quote the nums and separated by space in the final macro var*/
mod_num2keep= /*Default is empty for not filtering these elements by mod; when values, 
such as 2 or 3 are provided, only keep numbers that fulfil the mod(element,num)=0*/
);
				%global &outmacrovar;
				*This make the format include larger or negative numbers;
				/**Note: sometimes the negative numbers may be out of range of the format;
				%let numlength=%eval(%length(&end)+1);
                                %if %eval(&numlength<3) %then %let numlength=3;
                                */
                                *Use 8 as the default, which is even better, as the above will missing numbers, such as 0.666;
                                %let numlength=8;
				
				data range;
				*Make sure not to use if condition within the do loop in datastep;
				*otherwise, sas will run forever within the do loop!;
				do i=&st to &end by &by;
                                  output;
                                end;
                                run;

                                *Filter data and replace these selected values that can not be modded by scale value;
                                data range;
                                set range;
                                ord=_n_;
				 *scale the value i by scale;
                                 if i &filter4scaledvals then do;
                                    *Only keep these numbers can be modded by the &scale;
                                    *https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/ds2ref/n0t9j8b09x4uphn1kl1i70x63z19.htm;
                                    *If &scale<1, such as 0.3, 10*i/3=>remain*0.1;
                                    if mod(i,&scale)=0 then i=i/&scale;
                                    else i=round(i/&scale,0.1);
                                 end;
				run;

       %if %length(&mod_num2keep)>0 %then %do;
                data range;
                set range;
                *Note: only focus on i passed the filter of i &filter4scaledvals;
                if i &filter4scaledvals and mod(i,&mod_num2keep)^=0 then i=.;
                run;
       %end;
        
       
				proc sql noprint;
				%if %eval(&quote=1) %then %do;
				  select quote(prxchange("s/^\./ /",-1,trim(left(put(i,&numlength..1))))) 
                                  into: &outmacrovar separated by " "
                                %end;
				%else %do;
			          select prxchange("s/^\./ /",-1,trim(left(left(put(i,&numlength..1))))) into: &outmacrovar separated by " "
				%end;
				from range
				order by ord;
				drop table range;
				quit;

/*                              Can not replace these missing values as blank space, as later the global macro var seems be changed as local   */
/*				%let &outmacrovar=%sysfunc(rgxchange(s/\./ /,-1,&&&outmacrovar));                                              */

				%put generated numbers for the range from &st to &end by &by are: &&&outmacrovar;
%mend;

/* END companion/research/advanced_figures/sources/definitions/nums_in_range_adj_scale.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/rank4grps.sas */
%macro rank4grps(grps,dsdout);
data &dsdout;
length grps $300.;
%do i=1 %to %sysfunc(countw(%superq(grps),%str( )));
  %let gval=%qscan(%superq(grps),&i,%str( ));
  grps="&gval";num_grps=&i;
  output;
%end;
run;
proc sort data=&dsdout;by grps;
data &dsdout;
set &dsdout;
char_ord=_n_;
run;
proc sort data=&dsdout;by num_grps;
run;

%mend;

/* END companion/research/advanced_figures/sources/definitions/rank4grps.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/rows_in_sas_dsd.sas */
%macro rows_in_sas_dsd(test_dsd);
%local dsid nlobs rc;
%let nlobs=0;
%let dsid=%sysfunc(open(&test_dsd,IS));
%if &dsid=0 %then 
%put %sysfunc(sysmsg());

%let nlobs=%sysfunc(attrn(&dsid,NLOBS));
%let rc=%sysfunc(close(&dsid));

&nlobs

%if &nlobs gt 1 %then %do;
 %put There are &nlobs in your dataset;
%end;

%mend;

/* END companion/research/advanced_figures/sources/definitions/rows_in_sas_dsd.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/sas_dsd_exist.sas */
%macro sas_dsd_exist(sasdsd,lib=work);
%local sas_dt_exist;
%let sas_dt_exist=0;
%if %sysfunc(prxmatch(/\./,&sasdsd)) %then %do;
   %let lib=%scan(&sasdsd,1,.);
   %let sasdsd=%scan(&sasdsd,2,.);
%end;
%let sas_dt_exist=%sysfunc(exist(&lib..&sasdsd));
&sas_dt_exist
%mend;

/* END companion/research/advanced_figures/sources/definitions/sas_dsd_exist.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/scale_nums_in_list.sas */
%macro scale_nums_in_list(/*Note that the input list with or without double quotes should be delimited by space*/
list,
factor,
contain_double_quote=1
);
%local _list_ _a_;
%*remove double quotes if there;
%if &contain_double_quote=1 %then %do;
  %let list=%qsysfunc(prxchange(s/" "/ /,-1,&list));
  %let list=%qsysfunc(prxchange(s/"(.*)"/$1/,-1,&list));
  %*%put Input list has been removed for double quotes: &list;
%end;
%let _list_=;
%do li=1 %to %ntokens(&list);
				%let _a_=%sysevalf(&factor*%scan(&list,&li,%str( ))); 
        %let _list_=&_list_ &_a_;
%end;
%if &contain_double_quote^=1 %then %do;
        &_list_
%end;
%else %do;
				%let _list_="%sysfunc(prxchange(s/ /" "/,-1,&_list_))";
        &_list_
%end;
%mend;

/* END companion/research/advanced_figures/sources/definitions/scale_nums_in_list.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/select_element_range_from_list.sas */
%macro select_element_range_from_list(
list=,
st=1,	
end=,	/*If empty, the total number of elements will be used by it*/
sublist=sublist,/*Output a global macro variable for using by other SAS codes*/
sep=\s /*Perl regular expression for target separator (no | is allowed to match different separators)*/
);
%global &sublist;
%if %length(&end)=0 %then %let end=%ntokens(&list);
%let slcted_elems=%sysfunc(prxchange(s/^([^&sep]+&sep?){%sysevalf(&st-1)}(([^&sep]+&sep?){%sysevalf(&end-&st+1)}).*/\2/,-1,%bquote(&list))); 
*Need to remove the last separator;
*Note: the bquote for the macro var slcted_elems in case that it contain comma!;
%let slcted_elems=%sysfunc(prxchange(s/&sep$/ /,-1,%bquote(&slcted_elems)));
%put &slcted_elems;
%let &sublist=&slcted_elems;
%mend;

/* END companion/research/advanced_figures/sources/definitions/select_element_range_from_list.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/spaceAdjust.sas */
%macro spaceAdjust(
/*
 This macro can generate new numbers by adjusting its distance space
 in the sorted numbers, so please ensure the input dataset containing
numbers that are sorted in ascending order; if the input is a list, the macro
will generate a sorted dataset and generate adjust numbers automatically.
*/
data=, /*Input dsd with long format with vars like col1-coln
or a list containing blank space separated elements*/
out=, /*out dsd in long format but only contains one column AdjPos*/
goal=COL:,/*Target column vars in the input data set, such as col1-coln*/ 
sep=, /*Minimum distance to separate numbers in the input data set and 
adjust the number by ensuring its distances to left and right numbers
at least greater than the minimum distance*/
newvar4adjnum=AdjPos /*Create a new variable to contain these
position adjusted numers*/);

%if %ntokens(&data)>=1 and %sysfunc(prxmatch(/^\d[\.E\d\s]+/,&data/)) %then %do;
   %put The macro will transform the input list: &data;
   %put into a sas dataset in wide-format that all vars col1-coln containing these input elements;
   %rank4grps(
    grps=&data,
    dsdout=&out);
    data &out;
    set &out;
    value=grps+0;
    *Need to sort these numeric values;
    proc sort data=&out;by value;run;
    proc transpose data=&out(keep=value) out=&out(drop=_name_);
    var value;
    run;
    %let goal=col:;
    %let data=&out;
%end;

  *First save a copy of input dataset for later merging with adjust positions;
  data _old_;
  set &data;
  run;
/*proc print;run;*/
/*%abort 255;*/

%let nvars=%TotVarsInDsd(&data,var_type=_numeric_);
/*  %abort 255;*/
  *Now generate adjust positions for these input numbers;
/*
https://www.lexjansen.com/pharmasug/2010/CC/CC05.pdf
It is important to add options nosyntaxcheck here before the data step that is prone to error;
otherwise, other procedures followed the failed data step will be under the environment of 
options obs=0; adding this is the only solution when running sas codes in batch mode!
*/
OPTIONS NOSYNTAXCHECK;  
data &out.new;
        set &data.;
		*Need to make a copy for these input numbers;
        array u(*) u1-u&nvars;
		*The input numbers will be changed during evaluation in the array w;
        array w(*) &goal.;
        eps1000 = 1000*1E-12; /* SAS equivalent for precision */
        n = dim(w);
        v = &sep.;
        
        /* Initialize output */
		*Ensure these _i_ and _ii_ will not interupt other similar loop vars;
		do _i_=1 to n;
          u[_i_] = w[_i_];
		end;
        do _ii_ = 2 to n;
            w[_ii_] = max(w[_ii_-1] + v, u[_ii_]);
        end;
        
        moving = 1;
		*Only try 500 times optimization, which would prevent the macro run forever;
		nmoving=1;
        do while (moving and nmoving<=500);
            moving = 0;
			nmoving+1;

            i = 1;
			*It is important to restrict the i < n;
			*when i=n, the loop will fail;
            do while (i <n);
                /* Find next block */
                b = 0;
                do j = i to n-1;
                    b+1;*It is necessary to put b+1 here before the leave command!;
                    if abs(w[j+1] - w[j] - v) > eps1000 then leave;
                    /*b + 1;*/
                end;

				*Get the last block;
				*Important: assign b=n-1 if b=0;
				if b=0 then b=n-1;

                sum_u=0;
                sum_w=0;
                do jj=i to i+b;
                  sum_u+u[jj];
                  sum_w+w[jj];
                end;
                
                sh = sum_u/(1+b) - sum_w/(1+b);
                if abs(sh) > eps1000 then do;
				   if i=1 then leftLim=-1E12;
				   else leftLim=w[i-1]+v;
				   if i+b=n then rightLim=1E12;
				   else rightLim=w[i+b+1]-v;
/*				   The following will fail, as ifn will evaluate w[i-1] even when i=1;*/
/*                    leftLim  = ifn(i=1, -1E12, w[i-1] + v);*/
/*                    rightLim = ifn(i+b=n, 1E12, w[i+b+1] - v);*/
                    if w[i] + sh < leftLim then sh = leftLim - w[i];
                    if w[i+b] + sh > rightLim then sh = rightLim - w[i+b];
                    
                    do jjj = i to i+b;
                        w[jjj] = w[jjj] + sh;
                    end;
                    moving = 1;
                end;
                i = i + b + 1;
            end;
            
            /* Move singles */
			/*Use xi but not i*/

/*Matlab original codes for debugging;
	nloop=0;
    while ~isempty(i) && nloop<500
        k0 = abs(diff(w)-v)>eps1000;
        nloop=nloop+1;
        for i = find(([1 k0] & w>u) | ([k0 1] & w<u))
            if i==1; leftLim  =-inf; else leftLim  = w(i-1)+v; end
            if i==n; rightLim = inf; else rightLim = w(i+1)-v; end
            w(i) = max(min(u(i),rightLim),leftLim);
            moving = true;
        end
    end
end % moving
*The following implements the above matlab codes in SAS;
*/

		k0=1;
		niters=0;
		 do while (k0 and niters<=500);
            do xi = 1 to n;
			 if xi=1 and w[xi]>u[xi] then k0=1;
             if xi=n and w[xi]<u[xi] then k0=1; 
             if xi>1 and xi<n then k0 = abs(w[xi] - w[xi-1] - v) > eps1000;
                if k0 then do;
				   if xi=1 then leftLim=-1E12;
                   else leftLim  = w[xi-1] + v;
                   if xi=n then rightLim=1E12;
                   else rightLim = w[xi+1] - v;
                   w[xi] = max(min(u[xi], rightLim), leftLim);
                    moving = 1;
					*Note: when xi=n, the 1st while loop relying on moving=1 might break;
					*For debugging, comment out the following code to test the scenario;
					*if xi=n then moving=0;
					niters+1;
                end;
            end;
		 end;
        end;
    run;
/*proc print data=_old_;run;*/
/* %abort 255;*/
%if %totobsindsd(&out.new)=0 %then %do;
   %put failed to generate adjusted dataset &out.new;
   %put try to use the original input dataset &data without adjustment;
   OPTIONS NOSYNTAXCHECK;
   data &out;
   set _old_;
   run;
%end;
%else %do;
  data &out;
  set &out.new;
  run;
%end;
/*
proc print data=&out;run;
%abort 255;
*/

data &out;
set &out;
keep Col:;
proc transpose data=&out out=&out(rename=(col1=&newvar4adjnum) drop=_name_);
var Col:;
run;

*Now combine the adjust and original numbers;
proc transpose data=_old_ out=_old_(drop=_name_ rename=(col1=orig_num));
var _numeric_;
run;
data &out;
merge _old_ &out;
run;
proc datasets nolist;
delete _old_;
run;
%mend spaceAdjust;

/* END companion/research/advanced_figures/sources/definitions/spaceAdjust.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/totobsindsd.sas */
%macro totobsindsd(mydata);
    %let mydataID=%sysfunc(OPEN(&mydata.,IN));
    %let NOBS=%sysfunc(ATTRN(&mydataID,NOBS));
    %let RC=%sysfunc(CLOSE(&mydataID));
    %if "&NOBS"^="." %then %do;
      &NOBS
    %end;
    %else %do;
       0
    %end;
%mend;

/* END companion/research/advanced_figures/sources/definitions/totobsindsd.sas */

/* BEGIN companion/research/advanced_figures/sources/definitions/varexist.sas */
%macro varexist
/*----------------------------------------------------------------------
Check for the existence of a specified variable.
----------------------------------------------------------------------*/
(ds=        /* Data set name */
,var=       /* Variable name */);

/*----------------------------------------------------------------------
Usage Notes:

%if %varexist(&data,NAME)
  %then %put input data set contains variable NAME;

The macro calls resolves to 0 when either the data set does not exist
or the variable is not in the specified data set.
----------------------------------------------------------------------*/

%local dsid rc ;

/*----------------------------------------------------------------------
Use SYSFUNC to execute OPEN, VARNUM, and CLOSE functions.
-----------------------------------------------------------------------*/

%let dsid = %sysfunc(open(&ds));

%if (&dsid) %then %do;
  %if %sysfunc(varnum(&dsid,&var)) %then 1;
  %else 0 ;
  %let rc = %sysfunc(close(&dsid));
%end;
%else 0;

%mend varexist;

/* END companion/research/advanced_figures/sources/definitions/varexist.sas */

/* BEGIN companion/reader/figure_support.sas */
/* Output-copy helper; it does not recalculate test statistics. */
%macro af_export(data=,name=);
  data work.af_export_copy;set &data;format _numeric_ best32.;run;
  proc export data=work.af_export_copy
    outfile="&AF_OUT/&name..csv" dbms=csv replace;
  run;
%mend;

/* END companion/reader/figure_support.sas */

/* BEGIN companion/reader/regional_scope.sas */
/* Caller context required by the unchanged original regional macros.
   Matches the retained reference submission's global declarations.
   CHECK_VAR_TYPE writes VAR_TYPE with PROC SQL INTO; a name first
   created inside that helper otherwise disappears on return. */
%global chr_var dotsize var_type;

/* END companion/reader/regional_scope.sas */

/* BEGIN companion/research/publication_figures/support/publication_style.sas */
/* Book-owned presentation controls. Original research macros are unchanged. */
proc template;
 define style styles.BookPublication;
 parent=styles.journal;
 style GraphFonts from GraphFonts /
  'GraphTitleFont'=("Arial",9pt)
  'GraphLabelFont'=("Arial",9pt)
  'GraphValueFont'=("Arial",8.5pt)
  'GraphDataFont'=("Arial",8.5pt)
  'GraphUnicodeFont'=("Arial",8.5pt);
 end;
run;

%macro book_pub_gtl(in=,out=,chr=,start=,stop=,step=,decimals=1);
%local tick ticks;
%let ticks=;
%if %length(&chr) %then %do;
 proc format;
 value bookmb
 %do tick=&start %to &stop %by &step;
  &tick="%sysfunc(strip(%sysfunc(putn(%sysevalf(&tick/1000000),12.&decimals))))"
  %let ticks=&ticks &tick;
 %end;
 ;
 run;
%end;
data _null_;
 infile "&in" lrecl=32767 truncover;
 file "&out" lrecl=32767;
 length line $32767;
 input;line=_infile_;
 /* Captions identify the panel; avoid repeating a long headline in the image. */
 if index(lowcase(line),'entrytitle') then delete;
 line=tranwrd(line,'color=lightgray pattern=1 thickness=5',
                   'color=CXCCCCCC pattern=1 thickness=0.5');
 %if %length(&chr) %then %do;
 if index(lowcase(line),'xaxisopts=(') then do;
  line=prxchange('s/xaxisopts=\(label="[^"]*"/xaxisopts=(/',1,line);
  line=tranwrd(line,'xaxisopts=(',
    'xaxisopts=(label="Chromosome &chr position (Mb)" ');
 end;
 line=tranwrd(line,'tickvalueformat=best32.',
   'tickvalueformat=bookmb. tickvaluelist=(&ticks)');
 %end;
 put line;
run;
proc template;%include "&out";run;
%mend;

/* END companion/research/publication_figures/support/publication_style.sas */

/* BEGIN companion/research/track_proportions/support/track_display.sas */
/* Book-owned display pass: preserve every original macro-generated column. */
%macro book_track_display(data=,out=work.track_display,in=,template=,
 factor=0.5,body=16,single_marker=0,label_center_pct=,label_gap=0);
%local annvars allvars nann i compare_status;
/* SOURCE materializes the compiled template, including resolved local macro
   variables from book_pub_gtl (chromosome and tick list). */
proc template;source BedGraph / file="&BOOK_OUT/track_resolved_template.sas";run;
%let in=&BOOK_OUT/track_resolved_template.sas;
proc contents data=&data out=work.book_columns noprint;run;
proc sql noprint;
 select name into :annvars separated by ' ' from work.book_columns
 where prxmatch('/^VAR4LOG10P\d+$/i',strip(name)) order by varnum;
 select name into :allvars separated by ' ' from work.book_columns order by varnum;
quit;
%let nann=%sysfunc(countw(&annvars));
%if &single_marker %then %do;
 proc sql;
  create table work.book_group_order as select name from dictionary.columns
   where libname='WORK' and memname='MUTATION_WIDE' and upcase(substr(name,1,2))='P_'
   order by varnum;
 quit;
 data work.book_group_order;set work.book_group_order;pi=_n_;run;
 proc sql;
  create table work.book_occurrence_key as select distinct a.pos,b.pi
   from work.mutation_long a inner join work.book_group_order b
   on lowcase(a.panel)=lowcase(substr(b.name,3));
 quit;
%end;
data &out;
 %if &single_marker %then %do;
 if _n_=1 then do;
  declare hash occurrence(dataset:'work.book_occurrence_key');
  occurrence.defineKey('pi','pos');occurrence.defineDone();
 end;
 %end;
 set &data;
 array original_ann {*} &annvars;
 array display_ann {*} book_ann1-book_ann&nann;
 do book_i=1 to dim(original_ann);
  display_ann[book_i]=original_ann[book_i];
  if not missing(original_ann[book_i]) and original_ann[book_i]<0 then
   display_ann[book_i]=&factor*original_ann[book_i];
 end;
 book_gene_y=_y_;
 if not missing(_y_) and _y_<0 then book_gene_y=&factor*_y_;
 if not missing(book_gene_y) and book_gene_y<0 and grp_label ne ''
    and not missing(display_ann[1]) and display_ann[1]<0 then
  book_gene_y=max(book_gene_y,display_ann[1]+&label_gap);
 %if &single_marker %then %do;
 book_marker_pos=.;
 if grp='GWAS_Assoc_Signal' and not missing(old_y) and occurrence.check()=0 then book_marker_pos=pos;
 %end;
 drop book_i;
run;
/* Exact check of all original columns; extra display columns are excluded. */
proc compare base=&data compare=&out(keep=&allvars) criterion=0 noprint;run;
%let compare_status=&sysinfo;
data work.track_checks;
 compare_sysinfo=&compare_status;annotation_scale=&factor;body_thickness=&body;
 single_marker=&single_marker;
 if compare_sysinfo ne 0 then put 'ERROR: Original plotting columns changed.';
run;
%if %length(&label_center_pct) %then %do;
 proc sort data=&data(keep=_target_snp_ newpos where=(_target_snp_ ne ''))
  out=work.book_labels nodupkey;by _target_snp_;run;
%end;
data _null_;
 infile "&in" lrecl=32767 truncover;file "&template" lrecl=32767;
 length line token $32767;retain rx;
 if _n_=1 then rx=prxparse('/viewmin=(-[0-9.]+)/i');
 input;line=_infile_;
 /* Compress the negative annotation coordinates only, on the same x axis. */
 if prxmatch(rx,line) then do;
  call prxposn(rx,1,book_start,book_length);
  token=substr(line,book_start,book_length);
  line=tranwrd(line,cats('viewmin=',token),cats('viewmin=',put(input(token,best32.)*&factor,best32.)));
 end;
 if index(lowcase(line),'seriesplot x=') then do;
  %do i=1 %to &nann;
  line=tranwrd(line,"y=%upcase(%scan(&annvars,&i)) /","y=BOOK_ANN&i /");
  %end;
  line=prxchange("s/thickness=[0-9.]+(?:px|pt|in|cm|mm)?/thickness=&body.px/",1,line);
 end;
 line=tranwrd(line,'y=_Y_ /','y=BOOK_GENE_Y /');
 %if &single_marker %then %do;
 line=tranwrd(line,'scatterplot x=POS y=VAR4LOG10P /','scatterplot x=BOOK_MARKER_POS y=VAR4LOG10P /');
 %end;
 %if %length(&label_center_pct) %then %do;
 if index(lowcase(line),'textplot x=newpos') then do;
  /* Center the complete rotated string inside the reserved wall band. */
  do book_label_i=1 to book_nlabels;
   set work.book_labels point=book_label_i nobs=book_nlabels;
   put 'drawtext textattrs=(size=8) "' _target_snp_ +(-1)
    '" / x=' newpos best32. " y=&label_center_pct xspace=datavalue yspace=wallpercent anchor=center rotate=90;";
  end;
  delete;
 end;
 %end;
 put line;
run;
proc template;%include "&template";run;
%mend;

/* END companion/research/track_proportions/support/track_display.sas */

/* BEGIN companion/research/track_proportions/programs/track_isoforms.sas */
/* Real GRCh37 annotation; three explicitly selected CYP26B1 transcripts. */
data work.track_gtf;
  length type $10 genesymbol $12 ensembl_transcript $35;
  infile "~/poc261112_track_annotation.tsv" dsd dlm='09'x firstobs=2 truncover;
  input chr st end type :$10. genesymbol :$12. ensembl_transcript :$35. protein_coding;
  span=.;
run;
%let local_gtf_ods_html5=1;
ods listing close;
ods html5 path="&BOOK_OUT" gpath="&BOOK_OUT" file='tracks_native.html'
 options(bitmap_mode='LINK') image_dpi=300 style=BookPublication;
data work.isoform_input;
  length snp $35;
  infile "~/poc261112_isoform_associations.tsv" dsd dlm='09'x firstobs=2 truncover;
  input chr bp snp :$35. p z;
run;
%SNP_Local_Manhattan_With_GTF(gwas_dsd=work.isoform_input,chr_var=chr,
 AssocPVars=p,ZscoreVars=z,SNP_IDs=2:72350000:72380000,
 SNP_Var=snp,Pos_Var=bp,dist2snp=0,gtf_dsd=work.track_gtf,
 focus_on_transcript=1,gwas_labels_in_order=Female_PGC,
 design_width=760,design_height=450,image_dpi=300,
 dotsize=3,dist2sep_genes=50000,pct4neg_y=0.8,grp_font_size=8,
 fig_fmt=png,makedotheatmap=1,makeheatmapdotintooneline=0,
 heatmap_min_neg_val=-4,heatmap_max_pos_val=4,
 heatmap_Neg_rangealtcolormodel=CX2166AC CX92C5DE CXF7F7F7,
 heatmap_Pos_rangealtcolormodel=CXF7F7F7 CXF4A582 CXB2182B,
 heatmap_legend_title=%str(Source female Z),verbose=1);
data work.isoform_plot;set work.final;run;
options notes;
ods html5 close;
proc template;source BedGraph / file="&BOOK_OUT/isoforms_native_template.sas";run;
filename tsrc "&BOOK_OUT/isoforms_native_template.sas";
filename tout "&BOOK_OUT/isoforms_template.sas";
data _null_;
 infile tsrc lrecl=32767;file tout lrecl=32767;length line $32767;input;line=_infile_;
 if index(lowcase(line),'entrytitle') then line='entrytitle "Real PGC female associations and three CYP26B1 transcript isoforms";';
 put line;
run;
proc template;
%include tout;
run;
title;footnote;
ods listing gpath="&BOOK_OUT" image_dpi=300 style=BookPublication;
ods graphics / reset=index imagename='isoforms' imagefmt=png width=7.6in height=4.5in;
proc sgrender data=work.final template=BedGraph;dynamic _chr='CHR';run;
ods graphics / reset=index imagename='isoforms' imagefmt=svg width=7.6in height=4.5in;
proc sgrender data=work.final template=BedGraph;dynamic _chr='CHR';run;
ods listing close;

/* Presentation-only pass over the original macro-generated GTL. */
%book_pub_gtl(in=&BOOK_OUT/isoforms_template.sas,out=&BOOK_OUT/publication_template.sas,chr=2,start=72350000,stop=72380000,step=5000,decimals=3);
title;footnote;
ods listing gpath="&BOOK_OUT" image_dpi=450 style=BookPublication;
ods graphics / reset=index imagename='isoforms' imagefmt=png width=7.6in height=4.5in;
proc sgrender data=work.final template=BedGraph;dynamic _chr='CHR';run;
ods graphics / reset=index imagename='isoforms' imagefmt=svg width=7.6in height=4.5in;
proc sgrender data=work.final template=BedGraph;dynamic _chr='CHR';run;
ods listing close;

/* Book-owned proportions: raw macro tables remain unchanged. */
%book_track_display(data=work.final,out=work.track_display,in=&BOOK_OUT/publication_template.sas,template=&BOOK_OUT/track_template.sas,factor=1.4827,body=14,single_marker=0,label_center_pct=,label_gap=0.247110849);
title;footnote;
ods listing gpath="&BOOK_OUT" image_dpi=450 style=BookPublication;
ods graphics / reset=index imagename='isoforms' imagefmt=png width=7.6in height=4.5in;
proc sgrender data=work.track_display template=BedGraph;dynamic _chr='CHR';run;
/* Vector coordinates use native design resolution; avoid DPI-dependent SVG strokes. */
ods listing gpath="&BOOK_OUT" image_dpi=96 style=BookPublication;
ods graphics / reset=index imagename='isoforms' imagefmt=svg width=7.6in height=4.5in;
proc sgrender data=work.track_display template=BedGraph;dynamic _chr='CHR';run;
ods listing close;

/* END companion/research/track_proportions/programs/track_isoforms.sas */

options notes source;
ods _all_ close;
data work.poc_export;set work.track_gtf;format _numeric_ best32.;run;
proc export data=work.poc_export outfile="&BOOK_OUT/gene_gtf_0.csv" dbms=csv replace;run;
data work.poc_export;set work.isoform_input;format _numeric_ best32.;run;
proc export data=work.poc_export outfile="&BOOK_OUT/gene_gtf_1.csv" dbms=csv replace;run;
data work.poc_export;set work.isoform_plot;format _numeric_ best32.;run;
proc export data=work.poc_export outfile="&BOOK_OUT/gene_gtf_2.csv" dbms=csv replace;run;
data work.poc_export;set work.track_display;format _numeric_ best32.;run;
proc export data=work.poc_export outfile="&BOOK_OUT/gene_gtf_3.csv" dbms=csv replace;run;
data work.poc_export;set work.track_checks;format _numeric_ best32.;run;
proc export data=work.poc_export outfile="&BOOK_OUT/gene_gtf_4.csv" dbms=csv replace;run;
%put POC_COMPLETE=gene_gtf;
