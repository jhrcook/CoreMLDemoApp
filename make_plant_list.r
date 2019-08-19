
library(rvest)
library(tidyverse)

url <- "https://worldofsucculents.com/browse-succulents-scientific-name"
web_page <- read_html(url)
link_data <- html_nodes(web_page, ".links")


get_plant_names <- function(lnk) {
    txt <- html_text(lnk) %>%
        str_split("\n") %>%
        unlist()
    txt <- txt[!(str_detect(txt, "more") & str_detect(txt, "less"))]
    txt <- txt[!str_detect(txt, "\\+")]
    txt <- txt[txt != ""]
    txt <- str_remove_all(txt, "\'")
    txt <- str_replace_all(txt, "\u00A0", " ")  # to remove "&nbsp;"
    txt <- word(txt, start = 1, end = 2, sep = " ")
    return(unique(txt))
}

plant_names <- unlist(map(link_data, get_plant_names))
cat(plant_names, sep = "\n", file = "plant_names.txt")
cat(plant_names[1:5], sep = "\n", file = "plant_names_5.txt")


# save as JSON

plant_tib <- tibble(keywords = plant_names, limit = 5) %>%
    slice(1:3)

records_tib <- tibble(Records = list(plant_tib))


jsonlite::write_json(records_tib, path = "test.json", pretty = TRUE)