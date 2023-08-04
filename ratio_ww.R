## Read in data

data=read.csv("~/Downloads/covid_summary.csv",sep=",")
florida=data[data$geo_loc_name_sam == "USA: Florida",]
m=month(florida$collection_date_sam)
month <- function(x){
  a=substr(x,6,7)
  return(a)
}
florida_summary=data.frame(cbind(m,florida$waste_variants,florida$clinical_variants,
                                 florida$overlap_variants,
                                 (florida$waste_variants-florida$overlap_variants)/florida$waste_variants
                                 ))
florida_summary$V5[is.nan(as.numeric(florida_summary$V5))] <- 0
colnames(florida_summary) = c("month","waste_variants","clinical_variants","overlap_variants","ratio")

## Plot the violin plot for ratio of variants that are found only in wastewater
library(ggplot2)
library(Hmisc)
pdf("~/Downloads/Florida.pdf",height = 6,width = 10)
ggplot(florida_summary,aes(as.factor(month),as.numeric(ratio),fill=as.factor(month)))+
  geom_violin()+scale_y_log10()+
  stat_summary(fun.data = "mean_sdl", fun.args = list(mult = 1), geom = "pointrange", color = "white", size=1)+
  labs(title="2022 Florida")+
  xlab("Month")+ylab("ratio of variants only in wastewater")+
  theme(legend.position = "none",plot.title = element_text(size=12,hjust=0.5))
dev.off()