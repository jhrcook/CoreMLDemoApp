
# Filter out corrupt or WEBP images

library(magick)
library(tidyverse)

img_files <- list.files("downloads", recursive = TRUE, full.names = TRUE)
for (img_file in img_files) {
    img <- try(image_read(img_file))
    if (class(img) == "try-error") {
        cat("removing currupt file:", img_file, "\n")
        # file.remove(img_file)
    } else if (image_info(img)$format == "WEBP") {
        cat("removing WEBP file:", img_file, "\n")
        file.remove(img_file)
    }
}