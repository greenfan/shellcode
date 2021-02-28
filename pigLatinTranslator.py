#!/usr/bin/python3
import time
#
#
print("type a phrase to translate into pig Latin")
message = input()
VOWELS = ( 'a' , 'e', 'i', 'o', 'u', 'y' )
pigLatin = []
for word in message.split():
    
    #
    prefixNonLetters = ''
    while len(word) > 0 and not word[0].isalpha():
        prefixNonLetters += word[0]
        word = word[1:]
    if len(word) == 0:
        pigLatin.append(prefixNonLetters)
        continue
   #
    suffixNonLetters = ''
    while len(word) > 0 and not word[-1].isalpha():
        suffixNonLetters += word[-1]
        word = word[:-1]
    if len(word) == 0:
        pigLatin.append(reversed(suffixNonLetters))
        continue
    #
    # Upper and Title Check
    wordIsTitle = word.istitle()
    wordIsUpper = word.isupper()
    word = word.lower()
    #
    prefixConsonants = ''
    while len(word) > 0 and not word[0] in VOWELS:
        prefixConsonants += word[0]
        word = word[1:]
    #concatenate
    if prefixConsonants != '':
        word += prefixConsonants +  'ay'
    else:
        word += 'yay'
    #
    if wordIsTitle:
        word = word.title()
    if wordIsUpper:
        word = word.upper()

    pigLatin.append( prefixNonLetters + word + suffixNonLetters)
msg2 = f"Translating.... {message}"
print(msg2)
print(' '.join(pigLatin))
