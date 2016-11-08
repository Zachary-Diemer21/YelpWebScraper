__author__ = 'Zachary Diemer'
__date__ = 'April 19th, 2016'

from bs4 import BeautifulSoup
from selenium import webdriver
import csv
#from urlparse import urljoin

#Global Declarations
ZIP_URL = "zipcodes.txt"
path_to_chromedriver ='/home/zackymo/Desktop/chromedriver'
browser = webdriver.Chrome(executable_path = path_to_chromedriver)

def get_zips():
    f = open(ZIP_URL, 'r+')
    zips = [zcs.strip() for zcs in f.read().split('\n') if zcs.strip() ]
    f.close()
    return zips

#zipcodes = get_zips()

get_yelp_page = \
    lambda zipcode: \
        'http://www.yelp.com/search?find_desc=vape+shops&find_loc={0}'.format(zipcode)

#This synchronizes BeautifulSoup and Selenium
#The first command transfers the entire page into html
#and the second sets up bs - works beautifully
def make_soup(url):
    html = browser.page_source
    return BeautifulSoup(html, "lxml")

#use cases page_url = 'https://www.yelp.com/search?find_desc=vape+shops&find_loc=08100&ns=1'
#soup = make_soup(page_url)
#print soup



csvFile = open('vapeshops.csv', 'w')
fieldnames = ['bizname', 'addr','bizphone','numrevs']# 'cheapornah', 'rating', 'wifiavail']#,'cheapornah','rating', 'wifiavail']
writer = csv.DictWriter(csvFile, fieldnames=fieldnames, delimiter=',', lineterminator='\n')
writer.writeheader()



def gather_info(url):
    soup = make_soup(url)
    vapeshops = soup.find_all("div", {"class": "search-result"})
    for v in vapeshops:
        desc = {}
        try:
            desc['bizname'] = v.contents[1].find_all("a", {"class": "biz-name"})[0].text.encode("utf-8")
            #print bizname
        except: #Exception, e:
            pass#if verbose: print 'Business name extract fail', str(e)
        try:
            desc['addr'] = v.contents[1].find_all("address")[0].getText(separator=u', ').encode("utf-8") #works fully with commas
            #print addr
        except: #Exception, e:
            pass#if verbose: print 'Business address extract fail', str(e)
        try:
            desc['bizphone'] = v.contents[1].find_all("span", {"class": "biz-phone"})[0].text.encode("utf-8") #works
            #print bizphone
        except: #Exception, e:
            pass#if verbose: print 'Phone number extract fail', str(e)
        #print item.contents[1].find_all("div", {"class": "rating-large"}) #sort of works
        try:
            desc['numrevs'] = v.contents[1].find_all("span", {"class": "review-count"})[0].text.encode("utf-8") #works
            #print numrevs
        except: #Exception, e:
            pass#if verbose: print 'Number of reviews extract fail', str(e)
        """try:
            desc['cheapornah'] = v.contents[1].find_all("span", {"class": "price-range"}).encode("utf-8")
            print cheapornah
        except: #Exception, e:
            pass#if verbose: print ' extract fail', str(e)
        try:
            desc['rating'] = v.contents[1].find_all("div", {"class": "rating-large"}).encode("utf-8")
            print rating
        except: #Exception, e:
            pass#if verbose: print ' extract fail', str(e)
        try:
            desc['wifiavail'] = v.find('dd', {'class':'attr-WiFi'}).getText().encode("utf-8")
            print wifiavail
        except: #Exception, e:
            pass#if verbose: print 'Wifi availability extract fail', str(e)"""
        writer.writerow(desc)


def crawl():
    zipcodes = get_zips()
    for z in zipcodes:
            #Add the zipcode to the Base URL
            initial_url = get_yelp_page(z)
            #Log that info somehow
            print initial_url
            #Use Selenium to display the URL
            browser.get(initial_url)
            #Gather the specific information you are looking for
            gather_info(initial_url)
            #Attempt to go to the next page
            try:
                browser.find_element_by_css_selector('span[class=\"pagination-label u-align-middle responsive-hidden-small pagination-links_anchor\"]').click()
            except:
                pass
            #Create a new variable to update url over time
            prev_url = initial_url
            #Get the new page's url
            new_url = browser.current_url
            #counter = 0 - If I would like, I can output the number of businesses extracted in each zipcode
            #Continue this process until you go through 7 different pages or refresh 10 different times
            while prev_url != new_url: #and counter <= 10:
                prev_url = new_url
                gather_info(new_url)
                browser.get(new_url)
                try:
                    browser.find_element_by_css_selector('span[class=\"pagination-label u-align-middle responsive-hidden-small pagination-links_anchor\"]').click()
                except:
                    pass
                new_url = browser.current_url
                #counter += 1
            #Print counter or add to a text file with zipcode name here
