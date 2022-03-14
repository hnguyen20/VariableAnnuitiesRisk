load("xfeatures.Rdata")
rowdata_spec <- csv_record_spec("rowdata.csv")

dataset2 <- text_line_dataset("rowdata.csv", record_spec = rowdata_spec) 
dataset2 %>% dataset_prepare(x = xfeatures)
modelfile <- "tempmodel1.h5"  
currentmodel <- load_model_hdf5(modelfile,compile=FALSE)
predicted <- currentmodel %>%predict(dataset2) 
