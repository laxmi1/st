require "selenium-webdriver"

gem "test-unit"
require "test/unit"
require 'rubygems'
require 'time'

class Clicker1 < Test::Unit::TestCase 
 
# To open firefox browser and the application url
  def setup
    @driver = get_driver
    @accept_next_alert = true
    @verification_errors = [] 
  end
# Throws an assertion errors
  def teardown
    @driver.quit
    assert_equal [], @verification_errors
  end
  

  def get_driver
    Selenium::WebDriver::Chrome.driver_path="/home/laxmikanth/work/socialtrade/chromedriver"
    @driver = Selenium::WebDriver.for :chrome
    # @driver= Selenium::WebDriver.for :firefox
    # @base_url = "https://socialtrade.biz/User/dashboard.aspx"
    @base_url = "http://sserp.ablazeerp.com/login.aspx"
    @driver.manage.timeouts.implicit_wait = 10
    @driver.manage.window.maximize
    @wait = Selenium::WebDriver::Wait.new(:timeout => 200)
    @driver 
end

def login
    @driver.get(@base_url)
    # sleep 5
    # @driver.find_element(:xpath, "html/body/div[2]/div[1]/div").click
    # sleep 5
    @driver.find_element(:xpath, "//input[@placeholder='Enter Your User ID Here']").clear
    @driver.find_element(:xpath, "//input[@placeholder='Enter Your User ID Here']").send_keys "61700443"
    @driver.find_element(:xpath, "//input[@placeholder='Enter Your Password']").clear
    @driver.find_element(:xpath, "//input[@placeholder='Enter Your Password']").send_keys "Root@1234" 
    @driver.find_element(:xpath, "//input[@value='LOGIN']").click
end

# Test to login with valid credentials
  def test_clicker1 
     login
     # @driver.find_element(:xpath, "//img[@class='close-image']").click
     puts "popup closed"
     @driver.find_element(:link_text, "View Work").click
     sleep 10
     
     begin  
     rescue
     if @driver.find_element(:xpath, "html/body/form/div[7]/div/div[3]/div/input")
      @driver.find_element(:xpath, "html/body/form/div[7]/div/div[3]/div/input").click
      sleep 30
     end
     end 

     i = 1
     total = 250 
   # puts  @driver.find_element(:xpath, "html/body/form/div[6]/div/div[4]/div/div/tr["+i.to_s+"]/td[3]/span/b").text
    begin
      if @driver.find_element(:xpath, "html/body/form/div[5]/div/div[4]/div/div/tr["+i.to_s+"]/td[3]/span/b").text == "Clicked"
        puts "clicked"+i.to_s
        i = i+1
      else
        j = i
        begin
        # main_window = @driver.window_handle
        # @driver.find_element(:xpath, "html/body/form/div[6]/div/div[4]/div/div/tr["+i.to_s+"]/td[4]/span[1]/i").click
        # @driver.switch_to.window(main_window)
        # sleep 35
        # @driver.navigate().refresh()
        # wait = Selenium::WebDriver::Wait.new(:timeout => 10)
        # main_window = @driver.window_handle
        # wait.until { @driver.find_element(:xpath, "html/body/form/div[6]/div/div[4]/div/div/tr["+j.to_s+"]/td[4]/span[1]/i").displayed? }
        @driver.find_element(:xpath, "html/body/form/div[5]/div/div[4]/div/div/tr["+j.to_s+"]/td[4]/span[1]/i").click
        puts "clicked"+j.to_s
        # @driver.switch_to.window(main_window)
        sleep 40
        j= j+1
      end while j <= total
      end
    end while i <= total
  end


  
# To find the element and throws an error if element is not found.
   def element_present?(how, what)
    @driver.find_element(how, what)
    true
      rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

# To see the alert is present and throws an error if no alert is present
  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end
  
# To verify expected and actual values
# If assertion failed it throws an error
  def verify(&blk)
    yield
    rescue Test::Unit::AssertionFailedError => ex
    @verification_errors << ex
  end
  
# To close alerts
  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
    ensure
    @accept_next_alert = true
  end
end
# @driver.find_element(:xpath, "html/body/form/div[7]/div/div[3]/div/div[2]/div[1]/table/tbody/tr["+i.to_s+"]/td[3]/span").text == "Clicked"
# @driver.find_element(:xpath, "html/body/form/div[7]/div/div[3]/div/div[2]/div[1]/table/tbody/tr["+i.to_s+"]/td[4]/div/table/tbody/tr/td[1]/div/div/a/img").click