require "selenium-webdriver"
require "test/unit"
require 'rubygems'
require 'time'
gem "test-unit"

$user = ARGV[0]
$password = ARGV[1]
$table_rows = ARGV[2]

class Clicker < Test::Unit::TestCase 

    def setup
        puts "setup"
        @driver = get_driver
        @accept_next_alert = true
        @verification_errors = []
        @base_url = "https://socialtrade.biz"
        # @base_url = "http://sserp.ablazeerp.com/login.aspx"
        # @username = $user
        # @password = $password
        # if $user.nil? || $password.nil? || $table_rows.nil?
        #     puts "Please provide username, password and links count number."
        #     teardown
        # end
        # puts "logined user is : #{@username}"
    end

    # Throws an assertion errors
    def teardown
        @driver.quit
        assert_equal [], @verification_errors
    end

    def get_driver
        Selenium::WebDriver::Chrome.driver_path="./chromedriver"
        @driver = Selenium::WebDriver.for :chrome
        # @base_url = "https://socialtrade.biz"
        @base_url = "http://sserp.ablazeerp.com/login.aspx"
        @username = $user
        @password = $password
        puts "logined user is : #{@username}"
        @driver.manage.timeouts.implicit_wait = 10
        @driver.manage.window.maximize
        @wait = Selenium::WebDriver::Wait.new(:timeout => 200)
        @driver 
    end

    def login
        puts "logined user is : #{@username} and #{@password}"
        puts "connecting url is : #{@base_url}"
        begin
            @driver.get(@base_url)
        rescue => e
            puts "Site side issue, page not loaded properly."
            @driver.get(@base_url)
        end
        puts "page is loading please wait for 5 seconds"
        sleep 5
        begin
            @driver.find_element(:xpath, "//input[@placeholder='Enter Your User ID Here']").clear
            @driver.find_element(:xpath, "//input[@placeholder='Enter Your User ID Here']").send_keys @username
            @driver.find_element(:xpath, "//input[@placeholder='Enter Your Password']").clear
            @driver.find_element(:xpath, "//input[@placeholder='Enter Your Password']").send_keys @password 
            @driver.find_element(:xpath, "//input[@value='Sign In']").click
        rescue => e
        end
        puts "Login button clicked."
    end

    # Test to login with valid credentials
    def test_clicker
        begin
            login
            # sleep 5 
            # @driver.find_element(:xpath, "html/body/form/div[4]/div/div[2]/div[2]/img").click
            # sleep 5
            @driver.find_element(:link_text, "View Advertisements").click
            puts "View Advertisements button clicked."
            sleep 20
        rescue
            puts "enter in to rescue"
            # if @driver.find_element(:xpath, "html/body/form/div[4]/div/div[2]/div[2]/img")
            #     puts "enter in to if"
            #     @driver.find_element(:xpath, "html/body/form/div[4]/div/div[2]/div[2]/img").click
            #     sleep 30
            # end
        end

        count = links_clicking

        puts "#{count} rows completed."
       
    end


    def links_clicking
        i = 1
        count = 0
        begin
            begin
                # if @driver.find_element(:xpath, "html/body/form/div[3]/div/div[3]/div/div/div/div[3]/div[1]/div[2]/div[2]/div/tr["+i.to_s+"]/td[3]/span/b").text == "Clicked"
                if @driver.find_element(:xpath, "html/body/form/div[3]/div/div[3]/div/div/div/div[4]/table[2]/tbody/tr["+i.to_s+"]/td[3]/span/b").text == "Clicked"
                    puts "#{i} row already clicked."
                    count = count+1
                else
                    j = 1
                    begin
                        begin 
                            html/body/form/div[3]/div/div[3]/div/div/div/div[4]/table[2]/tbody/tr["+i.to_s+"]/td[4]/span[2]/i
                            # @driver.find_element(:xpath, "html/body/form/div[3]/div/div[3]/div/div/div/div[3]/div[1]/div[2]/div[2]/div/tr["+i.to_s+"]/td[4]/span[2]/i").click
                            @driver.find_element(:xpath, "html/body/form/div[3]/div/div[3]/div/div/div/div[4]/table[2]/tbody/tr["+i.to_s+"]/td[4]/span[2]/i").click
                            print "Clicked #{i} row: "
                            sleep 35
                        rescue
                        end
                        begin
                            if @driver.find_element(:xpath, "html/body/form/div[3]/div/div[3]/div/div/div/div[4]/table[2]/tbody/tr["+i.to_s+"]/td[3]/span/b").text == "Clicked"
                                print "Status done."
                                puts ""
                                count = count+1
                                break
                            else
                                print "Status not done, process repeat again."
                            end
                        rescue => e
                            print "Status not done, process repeat again."
                            puts ""
                        end
                        j= j+1
                    end while j <= 10
                end
                i = i+1
            rescue
                puts "something problem in row: #{i}"
            end
        end while i <= $table_rows.to_i
        return count
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

