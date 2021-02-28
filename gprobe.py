import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import random

browser = webdriver.Firefox()

file = open("textlist.txt", "r" )
memlist = file.read()
textlist = memlist.split("\n")
data = textlist
print(data)



def slow_type(element, text):
    """Send a text to an element one character at a time with a delay."""
    for character in text:
        element.send_keys(character)
        delay = ((random.random() / 2 ))
        time.sleep(delay)


for i in data:
    browser.get('https://www.google.com')
    time.sleep((random.random()) + 2)
    search = browser.find_element_by_name('q')
    slow_type(search, f"allintitle: {i}")
    search.send_keys(Keys.RETURN)
    time.sleep(5)
    try:
        search_results = browser.find_element_by_id("result-stats")
    except:
        print(f"NA, {i}")
        time.sleep(69)
        continue
    result_text = search_results.get_attribute("innerText").split()
    result_count = result_text[1]
    print(f'''{result_count}, {i}''')
    sleeptime = [ "20", "120",  "8", "11",  "77", "330", "50", "70", "36",  "61","120", "45", "77", "122", "60" ]
    s = " "
    gotosleep = s.join(random.choices(sleeptime))
    print(f"sleeping for {gotosleep} seconds...")
    time.sleep(int(gotosleep))


browser.quit()
