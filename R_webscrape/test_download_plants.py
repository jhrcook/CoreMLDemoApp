
from google_images_download import google_images_download   #importing the library

response = google_images_download.googleimagesdownload()   #class instantiation

with open("plant_names.txt") as fin:
    for line in fin:
        arguments = {"keyword": line, "limit": 5, "print_urls": True}
        paths = response.download(arguments)
        print(paths)
