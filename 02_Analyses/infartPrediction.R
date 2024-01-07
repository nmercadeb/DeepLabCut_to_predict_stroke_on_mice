library(here)
library(dplyr)
library(glmnet)
library(ggplot2)

## Prepare data ----
featuresDataFolder     = '01_Features'  
analysesFolder         = '02_Analyses'
figureFolder           = '03_Reporting/Results'

dades <- readxl::read_xlsx(gsub(analysesFolder, featuresDataFolder, here("dades.xlsx"))) 

# get only variables of interest
clean <- dades %>%
  dplyr::select("Mouse", "Infart", "Tape removal", "Video", "Test", "Tape side", "Ligature side",
           "Distance",	"Moving_time",	"vm_nose",	"vm_butt",	"vm_tail_end",	"vm_paw_IPSI",
           "vm_paw_CONTRA",	"vm_paw_ipsi",	"vm_paw_contra",	"d_Paws",	"Tail_curvature_C") %>%
  mutate(side = 
           case_when(
             grepl("AE", .data$Video) &  .data$`Ligature side` == "L" ~ "ipsi",
             grepl("AE", .data$Video) &  .data$`Ligature side` == "R" ~ "contra",
             grepl("AD", .data$Video) &  .data$`Ligature side` == "L" ~ "contra", 
             grepl("AD", .data$Video) &  .data$`Ligature side` == "R" ~ "ipsi"
           )
         ) %>%
  filter(Test != "TR - PRE") %>%
  filter(!is.na("vm_paw_ipsi")) %>%
  dplyr::select(c("Mouse", "Infart", "Tape removal", "Video", "Test", "side",
           "Distance",	"Moving_time",	"vm_nose",	"vm_butt",	"vm_tail_end",	"vm_paw_IPSI",
           "vm_paw_CONTRA",	"vm_paw_ipsi",	"vm_paw_contra",	"d_Paws",	"Tail_curvature_C")) %>%
  tidyr::pivot_wider(names_from = c("side"), 
                     names_prefix = "TR",
                     values_from = c("Tape removal"), 
                     values_fill = NA) %>%
  mutate(Test = substr(Test, 13, 16)) %>%
  group_by(Mouse, Infart, Test) %>%
  summarise("TRcontra" = mean(.data$TRcontra, na.rm = TRUE), 
            "TRipsi" = mean(.data$TRipsi, na.rm = TRUE),
            "Distance" = mean(.data$Distance, na.rm = TRUE), 
            "Moving_time" = mean(.data$Moving_time, na.rm = TRUE), 
            "vm_nose" = mean(.data$vm_nose, na.rm = TRUE), 
            "vm_butt" = mean(.data$vm_butt, na.rm = TRUE), 
            "vm_tail_end" = mean(.data$vm_tail_end, na.rm = TRUE), 
            "vm_paw_IPSI" = mean(.data$vm_paw_IPSI, na.rm = TRUE), 
            "vm_paw_CONTRA" = mean(.data$vm_paw_CONTRA, na.rm = TRUE), 
            "vm_paw_ipsi" = mean(.data$vm_paw_ipsi, na.rm = TRUE), 
            "vm_paw_contra" = mean(.data$vm_paw_contra, na.rm = TRUE), 
            "d_Paws" = mean(.data$d_Paws, na.rm = TRUE), 
            "Tail_curvature_C" = mean(.data$Tail_curvature_C, na.rm = TRUE), 
            .groups = "drop") %>%
  filter(!is.na(Tail_curvature_C))

lasso_data <- clean %>%
  tidyr::pivot_wider(names_from = c("Test"), 
                     values_from = c("TRipsi", "TRcontra",
                                     "Distance",	"Moving_time",	
                                     "vm_nose",	"vm_butt",	"vm_tail_end",	"vm_paw_IPSI",
                                     "vm_paw_CONTRA",	"vm_paw_ipsi",	"vm_paw_contra",	
                                     "d_Paws",	"Tail_curvature_C"), 
                     values_fill = 0)  
lasso_data <- lasso_data %>%
  filter(!if_any(names(lasso_data), ~is.na(.x)))


## Infart lasso ----
nam <- names(lasso_data)
contributions <- rep(0, length(nam)-1)
names(contributions) <- names(lasso_data[,-1])

X <- as.matrix(lasso_data %>% dplyr::select(-Infart, -Mouse))
Y <- lasso_data$Infart
lambdas   <- 10^seq(2, -3, by = -.1)

for (ii in 1:100) {
  lasso_reg <- cv.glmnet(X, Y, alpha = 1, lambda = lambdas, standardize = TRUE, nfolds = 5, family = "gaussian")
  coef.lasso_reg <- coef(lasso_reg, s = lasso_reg$lambda.1se)
  var.lasso_reg  <- names(coef.lasso_reg[(coef.lasso_reg[,1]!=0),1])[-1]
  var.lasso_reg  <- gsub("`", "", var.lasso_reg)
  
  contributions[which(names(contributions) %in% var.lasso_reg)] <- contributions[which(names(contributions) %in% var.lasso_reg)] + 1
}

contributions_infart <- contributions[contributions > 0]
predictors <- names(contributions)[contributions > 75]
id_col          <- which(nam %in% c(predictors, "Infart", "Mouse"))

infart_model_data <- lasso_data[,id_col] 

infart_model <- lm(Infart ~ ., data = infart_model_data %>% dplyr::select(-Mouse))
summary(infart_model)

r2 <- 1 - ( sum((infart_model_data$Infart-infart_model$fitted.values)**2, na.rm = TRUE) / sum((infart_model_data$Infart - mean(infart_model_data$Infart))**2 ))
n = 24
k = length(predictors)
r2a <- 1 - (((1-r2) * (n - 1))/(n - k - 1))
rmsa = sqrt(sum((infart_model$fitted.value-infart_model_data$Infart)^2)/length(infart_model_data$Infart))

# test:
predicted_infart <- NULL
observed_infart <- NULL
for (ii in 1:300) {
  test_id <- sample(infart_model_data$Mouse, 4)
  test <- infart_model_data %>% 
    filter(Mouse %in% test_id) %>% 
    dplyr::select(-Mouse)
  train <- infart_model_data %>% 
    anti_join(test, 
              by = c("Infart", "TRcontra_24H")) %>% 
    dplyr::select(-Mouse)
  mdl = lm(Infart ~ ., train)
  predicted_infart <- c(predicted_infart, predict(mdl, test))
  observed_infart <- c(observed_infart, test$Infart)
}

r2 <- 1 - ( sum((observed_infart-predicted_infart)**2, na.rm = TRUE) / sum((observed_infart - mean(observed_infart))**2 ))
n = 20
k = length(predictors)
r2a <- 1 - (((1-r2) * (n - 1))/(n - k - 1))
rmsa = sqrt(sum((predicted_infart-observed_infart)^2)/length(predicted_infart))

ss_id <- which(observed_infart > 0 & observed_infart > 28)
ms_id <- which(observed_infart > 0 & observed_infart <= 28)
TSS = sum(predicted_infart[ss_id] > 28) / length(ss_id)
TMS = sum(predicted_infart[ms_id] <= 28) / length(ms_id)
FSS = sum(predicted_infart[ms_id] > 28) / length(ms_id)
FMS = sum(predicted_infart[ss_id] <= 28) / length(ss_id)

## Stroke lasso ----
nam <- names(lasso_data)
contributions <- rep(0, length(nam)-1)
names(contributions) <- names(lasso_data[,-1])

X <- as.matrix(lasso_data %>% dplyr::select(-Infart, -Mouse))
Y <- lasso_data$Infart > 0
lambdas   <- 10^seq(2, -3, by = -.1)

for (ii in 1:100) {
  lasso_reg <- cv.glmnet(X, Y, alpha = 1, lambda = lambdas, standardize = TRUE, nfolds = 5, family = "binomial")
  coef.lasso_reg <- coef(lasso_reg, s = lasso_reg$lambda.1se)
  var.lasso_reg  <- names(coef.lasso_reg[(coef.lasso_reg[,1]!=0),1])[-1]
  var.lasso_reg  <- gsub("`", "", var.lasso_reg)
  
  contributions[which(names(contributions) %in% var.lasso_reg)] <- contributions[which(names(contributions) %in% var.lasso_reg)] + 1
}

contributions_stroke <- contributions[contributions > 0]
predictors <- names(contributions)[contributions > 75]
id_col          <- which(nam %in% c(predictors, "Infart", "Mouse"))

stroke_model_data <- lasso_data[,id_col] %>% 
  mutate(Infart = 
           if_else(Infart > 0,
                   1,
                   0)) 

stroke_model <- glm(Infart ~ ., data = stroke_model_data %>%
                      dplyr::select(-Mouse), family = binomial(link = "logit"))
summary(stroke_model)

# test:
predicted_stroke <- NULL
observed_stroke <- NULL
for (ii in 1:300) {
  test_id <- sample(stroke_model_data$Mouse, 4)
  test <- stroke_model_data %>% 
    filter(Mouse %in% test_id) %>% 
    mutate(Infart = 
             if_else(Infart > 0,
                     1,
                     0)) 
  train <- stroke_model_data %>% 
    mutate(Infart = 
             if_else(Infart > 0,
                     1,
                     0)) %>%
    anti_join(test, 
              by = c("Infart", "TRcontra_72H")) %>% 
    dplyr::select(-Mouse)
  mdl = glm(Infart ~ ., data = train, family = binomial(link = "logit"))
  pred_temp <- predict.glm(mdl, 
                           test %>% 
                             dplyr::select(-Mouse),
                           "response")
  names(pred_temp) <- test$Mouse
  predicted_stroke <- c(predicted_stroke, pred_temp)
  observed_stroke <- c(observed_stroke, test$Infart)
}

accuracy = sum(observed_stroke == (predicted_stroke > 0.5))/length(observed_stroke)
accuracy = sum(stroke_model_data$Infart == 
                 (predict.glm(stroke_model, 
                              stroke_model_data %>% 
                                dplyr::select(-Mouse),
                              "response") 
                  > 0.5))/length(stroke_model_data$Infart)



## Report ----
## Infart
ggplot(data = tibble(observed = infart_model_data$Infart,
                     predicted = predict(infart_model,
                                         infart_model_data)), 
       aes(x = observed, y = predicted))  +
  geom_rect(aes(xmin = 0, xmax = 28, ymin = 0, ymax = 28), 
            fill = "green", 
            alpha = 0.005, 
            color = "green",
            linetype = 0) +
  geom_rect(aes(xmin = 28, xmax = 70, ymin = 28, ymax = 70), 
            fill = "green", 
            alpha = 0.005, 
            color = "green",
            linetype = 0) +
  geom_rect(aes(xmin = 0, xmax = 28, ymin = 28, ymax = 70), 
            fill = "red", 
            alpha = 0.005, 
            color = "red",
            linetype = 0) +
  geom_rect(aes(xmin = 28, xmax = 70, ymin = 0, ymax = 28), 
            fill = "red", 
            alpha = 0.005, 
            color = "red",
            linetype = 0) +
  geom_abline(slope = 1, intercept = 0, color = "#3a5a40", linewidth = 1) +
  geom_hline(yintercept = 28, linetype = "dashed") +
  geom_vline(xintercept = 28, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  xlab("Observed IBV (%)") +
  ylab("Predicted IBV (%)") +
  scale_y_continuous(breaks = seq.int(0,80,10), limits = c(0,70)) +
  scale_x_continuous(breaks = seq.int(0,80,10), limits = c(0,70)) +
  geom_point(data = tibble(observed = observed_infart,
                           predicted = predicted_infart), 
             aes(x = observed, y = predicted), size = 2, shape = 18, color = "#a3b18a") +
  geom_point(size = 2, color = "#537A5A") +
  theme_minimal() 


ggsave(
  gsub(analysesFolder, figureFolder, here("fig7_infartModel_background.png")),
  last_plot(),
  width = 5,
  height = 5
)

ggplot(data = tibble(observed = infart_model_data$Infart,
                     predicted = predict(infart_model,
                                         infart_model_data)), 
       aes(x = observed, y = predicted))  +
  geom_abline(slope = 1, intercept = 0, color = "#3a5a40", linewidth = 1) +
  geom_hline(yintercept = 28, linetype = "dashed") +
  geom_vline(xintercept = 28, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  xlab("Observed IBV (%)") +
  ylab("Predicted IBV (%)") +
  scale_y_continuous(breaks = seq.int(0,80,10), limits = c(0,70)) +
  scale_x_continuous(breaks = seq.int(0,80,10), limits = c(0,70)) +
  geom_point(data = tibble(observed = observed_infart,
                           predicted = predicted_infart), 
             aes(x = observed, y = predicted), size = 2, shape = 18, color = "#a3b18a") +
  geom_point(size = 2, color = "#537A5A") +
  theme_minimal() 


ggsave(
  gsub(analysesFolder, figureFolder, here("fig7_infartModel.png")),
  last_plot(),
  width = 5,
  height = 5
)

## Stroke
stroke_id <- which(observed_stroke == 1)
noStroke_id <- which(observed_stroke == 0)
TP = sum(predicted_stroke[stroke_id] > 0.5) / length(predicted_stroke)
TN = sum(predicted_stroke[noStroke_id] <= 0.5) / length(predicted_stroke)
FP = sum(predicted_stroke[noStroke_id] > 0.5) / length(predicted_stroke)
FN = sum(predicted_stroke[stroke_id] <= 0.5) / length(predicted_stroke)

sensitivity = TP/(FN+TP)
specificity = TN/(FP+TN)

PPV = TP/(TP+FP)
NPV = TN/(TN+FN) 
  
