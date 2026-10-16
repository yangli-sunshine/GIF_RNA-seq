library(dplyr)
species<-read.table('species-list.txt',header = F,sep = ',',col.names = 'species')
species<-species$species

FPKM_func<-function(spe){
  count<-read.table(paste0('count/',spe,'_count.txt'),header = T,sep = '\t',fill = T,row.names = 1)|>as.matrix()
  KB=count[,1]/1000   
  counts = count[,-1]
  RPK=counts/KB
  RPK <- as.matrix(RPK)
  counts <- as.matrix(counts)
  TPM = t(t(RPK)/colSums(RPK)*10^6)
  FPKM = t(t(RPK)/colSums(counts)*10^6)
  FPKM|>str()|>print()
  group <- sub("\\.\\d+$", "", colnames(FPKM))
  
  result <- FPKM %>%
    as.data.frame() %>%
    mutate(Gene = rownames(FPKM)) %>%
    tidyr::pivot_longer(-Gene, names_to = "sample", values_to = "value") %>%
    mutate(group = sub("\\.\\d+$", "", sample)) %>%
    group_by(Gene, group) %>%
    summarise(mean = mean(value), .groups = "drop") %>%
    tidyr::pivot_wider(names_from = group, values_from = mean)
  names(result)[2:length(result)]<-paste0('FPKM',seq(1,length(result)-1))
  write.csv(result,paste0(spe,'FPKM.txt'),quote = F,row.names = F)
}

sapply(species,FPKM_func)

