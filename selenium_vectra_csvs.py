
import time
import requests
from bs4 import BeautifulSoup

from selenium import webdriver
from selenium.webdriver.common.keys import Keys

options = webdriver.ChromeOptions()
options.add_argument('--ignore-certificate-errors')
options.add_argument('--incognito')
options.add_argument('--headless')




options.add_experimental_option("prefs", {
  "download.default_directory": r"/tmp/",
  "download.prompt_for_download": False,
  "download.directory_upgrade": True,
  "safebrowsing.enabled": True
})


driver = webdriver.Chrome("/home/kali/Downloads/chromedriver", chrome_options=options)




driver.get("https://10.1.199.15/")

username = driver.find_element_by_css_selector("#id_username")
print(username)
#driver.sendKeys("rdwyer" + Keys.TAB + "yellowhoneyyellowhoney");
passwordbox = driver.find_element_by_css_selector("#id_password")

username.send_keys("rdwyer" + Keys.TAB );
passwordbox.send_keys("yellowhoneyyellowhoney" + Keys.ENTER );

print("great we are logged in")



networkbutton = driver.find_element_by_css_selector(".traffic")
print(networkbutton)

time.sleep(2)


driver.find_element_by_css_selector(".traffic").click()

time.sleep(2)


devicesbutton = driver.find_element_by_xpath("/html/body/div[1]/div[3]/div[1]/nav/ul/li[2]")
print(devicesbutton)
driver.find_element_by_xpath("/html/body/div[1]/div[3]/div[1]/nav/ul/li[2]").click()
time.sleep(3)
final = driver.find_element_by_xpath("/html/body/div[1]/div[3]/div[1]/div/div[3]/main/div/section/header/a")
print("found it.")
print(final)

time.sleep(3)
file = driver.find_element_by_xpath("/html/body/div[1]/div[3]/div[1]/div/div[3]/main/div/section/header/a").click()
print("Okay, I clicked it."
#page = driver.page_source
