import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
import random

browser = webdriver.Firefox()

data = ["gtaV cheats","chess","gta5 mods"]




def slow_type(element, text):
    """Send a text to an element one character at a time with a delay."""
    for character in text:
        element.send_keys(character)
        delay = (random.random())
        time.sleep(delay)


for i in data:
    browser.get('https://www.google.com')
    time.sleep((random.random()) + 2)
    search = browser.find_element_by_name('q')
    slow_type(search, f"allintitle: {i}")
    search.send_keys(Keys.RETURN)
    time.sleep(5)
    search_results = browser.find_element_by_id("result-stats")
    result_text = search_results.get_attribute("innerText").split()
    result_count = result_text[1]
    print(f"Got {result_count} results for {i}")
    time.sleep(5)


browser.quit()

