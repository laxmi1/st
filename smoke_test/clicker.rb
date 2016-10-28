load File.dirname(__FILE__) +  '/../test_helper.rb'
load File.dirname(__FILE__) +  '/../test_helper.rb'

class Clicker < Test::Unit::TestCase 
  fixtures :users

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
  
# Test to login with valid credentials
  def test_clicker

  
   login

   # @driver.find_element(:xpath, "//img[@class='close-image']").click

   puts "popup closed"

   @driver.find_element(:link_text, "View Work").click

   sleep 10


   i = 1
   total = 125 

   # puts  @driver.find_element(:xpath, "html/body/form/div[6]/div/div[4]/div/div/tr["+i.to_s+"]/td[3]/span/b").text

    begin
      if @driver.find_element(:xpath, "html/body/form/div[6]/div/div[4]/div/div/tr["+i.to_s+"]/td[3]/span/b").text == "Clicked"
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
        @driver.find_element(:xpath, "html/body/form/div[6]/div/div[4]/div/div/tr["+j.to_s+"]/td[4]/span[1]/i").click
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