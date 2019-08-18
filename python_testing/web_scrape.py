from bs4 import BeautifulSoup
from urllib.request import urlopen
import ssl

context = ssl._create_unverified_context()
resp = urlopen("https://www.google.com", context=context)
# soup = BeautifulSoup(resp, from_encoding=resp.info().getparam('charset'))

print(resp)

#for link in soup.find_all('a', href=True):
#    print(link['href'])


