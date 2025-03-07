library(readxl)
library(dplyr)

setwd("/data5/bio/MolGenMicro/across_ncbi_data")

if (!requireNamespace("openxlsx", quietly = TRUE)) {
  install.packages("openxlsx")
}

library(openxlsx)
filename <- "./mtb_table.xlsx"

# Читаем данные
data6 <- read_excel(filename, sheet = "data6")
data15 <- read_excel(filename, sheet = "data15")
ncbi <- read_excel(filename, sheet = "ncbi")

# Приводим столбец tstv к типу character в обеих таблицах
data6$tstv <- as.numeric(data6$tstv)
data15$tstv <- as.numeric(data15$tstv)


# Объединяем data6 и data15; если есть дубликаты по Sample, оставляем одну запись.
data_combined <- bind_rows(data6, data15) %>%
  distinct(Sample, .keep_all = TRUE)

# Левое объединение: данные из ncbi дополняются информацией из data_combined по совпадению Run = Sample.
res <- ncbi %>%
  left_join(data_combined, by = c("Run" = "Sample"))


# Преобразуем все столбцы в character и заменяем NA на пустую строку
res <- res %>%
  mutate(across(everything(), ~ ifelse(is.na(.), "", as.character(.))))

res <- res %>% select(-download_path, -ReadHash, -RunHash, -Consent)
res <- res %>% select(-Consent)

# Записываем результат в файл с разделителями табуляции (TSV)
write.table(res, file = "across-stats.tsv", sep = "\t", row.names = FALSE, quote = FALSE)

openxlsx::write.xlsx(res, file = "across-stats.xlsx", asTable = TRUE)

