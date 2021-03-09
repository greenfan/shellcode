#!/usr/bin/python3
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.options import Options

import random
import re
import os
os.system("mv result.csv old_result.txt")
os.system("touch result.csv")
file = open("textlist.txt", "r" )
memlist = file.read()
textlist = memlist.split("\n")
data = textlist
print(data)
result_file = open("result.csv", "a")

result_file.write(f" , \n")

def slow_type(element, text):
    """Send a text to an element one character at a time with a delay."""
    for character in text:
        element.send_keys(character)
        delay = (random.random())
        time.sleep(delay)
#whilte ( webbrowser is running )


print('''
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            ______              
         .-'      `-.           
       .'            `.         
      /                \        
     ;    GOOGLE       ;`       
     |      POWER      |;       
     ;       PROBER    ;|
     '\               / ;       
      \`.           .' /        
       `.`-._____.-' .'         
         / /`_____.-'           
        / / /                   
       / / /
      / / /
     / / /
    / / /
   / / /
  / / /
 / / /
/ / /
\/_/

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@ TYPE 'y' to run headless @@@@@@@@@@
''')





headless_value = input()
os.system("clear")
time.sleep(1)



for text in "Let's get this bread...":
    print(text)
    time.sleep((random.random() / 3))

if headless_value != "y":
    browser = webdriver.Firefox()
    print("running in GUI")
else:
    options = Options()
    options.headless = True
    browser = webdriver.Firefox(options=options)
    print("running headless")

    

for i in data:
    try:
        browser.get('https://www.google.com')
    except:
        time.sleep(300)
        pass
    time.sleep((random.random()) + 2)
    search = browser.find_element_by_name('q')
    slow_type(search, f"allintitle: {i}")
    search.send_keys(Keys.RETURN)
    time.sleep((13 + ((random.random() *3 ))))
    try:
        search_results = browser.find_element_by_id("result-stats")
    except:
        captchacheck = ''
        try:
            captchacheck = browser.find_element_by_id("recaptcha")
        except:
            pass
        if captchacheck != '':
            print("we got caught.. sleeping")
            time.sleep(699)
        print(f"NA, {i}\n")
        result_file.write(f"NA, {i}\n")
        time.sleep(9)
        continue
    result_text = search_results.get_attribute("innerText").split()
    result_count = result_text[0] + ' ' + result_text[1] + ' ' + result_text[2]
    result_count = re.sub('results', '', result_count)
    result_count = re.sub('result', '', result_count)
    result_count = re.sub('About', '', result_count)
    result_file.write(f"{result_count},{i}\n")
    print(f'''{result_count}, {i}''')
    sleeptime = [ "20", "120",  "8", "11",  "77", "330", "50", "70", "36",  "61","120", "45", "77", "122", "60","33", "330", "28", "38", "61", "71" ]
    s = " "
    gotosleep = s.join(random.choices(sleeptime))
    time.sleep(int(gotosleep)) 
    
     
browser.quit()
os.system("ps faux | grep -ie .*fire.* | awk '{prent $2}'")
print("finished google search parsing, closing")
time.sleep(3)
os.system(" cat result.csv | sed s'/([^,]*//g' > $(date +%d%m)_result.csv ")
print("results from today's run have been written and parsed.)
