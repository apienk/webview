import unittest
from selenium import webdriver

class DeletePage(unittest.TestCase):
    '''
    This test will create a Page and delete it.
    It makes one assumption in order for the test to work:
      * Assumes the new Page is the first item in the Workspace Page list
    '''

    authkey = ""
    pw = ""
    url = ""


    def setUp(self):
        self.driver = webdriver.Firefox()
        propfile = open('properties.ini')
        items = [line.rstrip('\n') for line in propfile]
        self.authkey = items[0]
        self.pw = items[1]
        self.url = items[2]

    def tearDown(self):
        self.driver.quit()

    def test_page_deletion(self):
        self.driver.get(self.url)
        self.driver.implicitly_wait(300)
        #login
        authKey = self.driver.find_element_by_name('auth_key')
        authKey.send_keys(self.authkey)
        pw = self.driver.find_element_by_name('password')
        pw.send_keys(self.pw)
        signin = self.driver.find_element_by_css_selector('button.standard')
        signin.click()
        self.driver.implicitly_wait(300)
        #add page
        addbutton = self.driver.find_element_by_xpath("(//button[@type='button'])[3]")
        addbutton.click()
        listItem = self.driver.find_element_by_css_selector('li.menuitem.new-book')
        listItem.click()
        #add title to modal
        modal = self.driver.find_element_by_id('new-media-modal')
        titlefield = modal.find_element_by_name('title')
        titlefield.send_keys('Selenium Test Book')
        createbutton = self.driver.find_element_by_xpath("//button[@type='submit']")
        createbutton.click()
        self.driver.set_page_load_timeout(10)
        #click back button
        self.driver.find_element_by_css_selector('span.tab-title')
        #Webdriver does something funny with the history, so have to call back() multiple times
        self.driver.back()
        self.driver.back()
        self.driver.back()
        #delete page
        delete = self.driver.find_element_by_xpath('//table[1]/tbody/tr[1]/td[5]')
        delete.click()
        okbutton = self.driver.find_element_by_xpath("(//button[@type='button'])[6]")
        okbutton.click()

if __name__ == "__main__":
    unittest.main()

