## script pour préparer les données qui serviront à créer les modèles de classification

library(dplyr)


setwd("C:/Users/sarah/OneDrive - UQAM/PaqLab/Sarah/CytoR/data_reference")
getwd()
## charger les données de pollen de référence
data<-read.csv("references_pollens_all.csv", h=T)
names(data)[1]<-"Cytometry_Name_pollens"
## charger le tableau qui contient le nom des échantillons et 
names<-read.csv("Collection_Reference_Pollens.csv", sep= ";",h=T)

data2<-left_join(data, names, by="Cytometry_Name_pollens")
data2$Cytometry_Name_debris<- NULL
  
training<-dplyr::select(data2, -Cytometry_Name_pollens, -Time, -SampleID)
#training$Class<-as.factor("Pollens")
training$Class<-as.factor(paste(training$Genus, training$Species, sep = "_"))
training$Genus<-as.factor(training$Genus)
training$Family<-as.factor(training$Family)
training$Cytometry_Name<-as.factor(training$Cytometry_Name)

training$Species<-NULL
str(training)

## ajouter les débris
deb<-read.csv("references_debris_all.csv", h=T)
deb1 <- deb[sample(nrow(deb),10000),] ## garder seulement 10000 débris
names(deb1)[1]<-"Cytometry_Name_debris"
deb2<-left_join(deb1, names, by="Cytometry_Name_debris")

deb2<-dplyr::select(deb2, -Cytometry_Name_debris,-Cytometry_Name_debris,-Cytometry_Name_pollens, -Time, -SampleID,-Species)
deb2$Class<-as.factor("Debris")
str(deb2)



## combine training et deb2
training2<-rbind(training, deb2)

## nettoyage, pour supprimer les lignes sans valeurs (inf, NA)
completerecords <- na.omit(training2) 
completerecords2 <-  completerecords %>% 
  filter_if(~is.numeric(.), all_vars(!is.infinite(.))) # checking only numeric columns:

## S'il y a moins d'obs. dans completerecords2 que dans training, regarder pourquoi ! 
## possible problème dans le nom d'échantillons de référence et mauvaise liaison avec names
## il ne devrait pas y avoir de NA ou de inf normalement

## placement aléatoire des lignes (ID)
datamod <- completerecords2[sample(nrow(completerecords2)),]

## nettoyage (garde seulement le tableau datamod dans les fichiers à droite)
rm(list=setdiff(ls(), "datamod"))

## occurrence de chaque espèce
as.data.frame(table(datamod$Class))

## table d'entraînement et de test du modèle
index     <- 1:nrow(datamod)
testindex <- sample(index, trunc(length(index)*30/100))
testset   <- datamod[testindex,]
trainset  <- datamod[-testindex,]

## sauvegarder les données de train et test !!!
write.csv(datamod, 'trainingdata.csv', row.names = F) ## jeux de données complet
write.csv(trainset, 'trainset.csv', row.names = F) ## jeux de données pour entraîner le modèle
write.csv(testset, 'testset.csv', row.names = F) ## jeux de données pour tester le modèle

