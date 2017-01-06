require "selenium-webdriver"
require "test/unit"
require 'rubygems'

$user = ARGV[0]
$password = ARGV[1]
$table_rows = ARGV[2]
$pending_date = ARGV[3]

class Clicker < Test::Unit::TestCase 

    def setup
        puts "setup"
        @driver = get_driver
        @accept_next_alert = true
        @verification_errors = []
        @base_url = "https://www.socialtrade.biz"
        #@base_url = "http://sserp.ablazeerp.com"
        @username = $user
        @password = $password
    end

    def get_driver
        #set the chrome browser path here, if its not set the path it will run in Google Chrome browser.
        # Selenium::WebDriver::Chrome.path = "/usr/bin/chromium-browser"
        # @driver = Selenium::WebDriver.for :chrome, driver_path: './chromedriver'
        @driver= Selenium::WebDriver.for :firefox
        @driver.manage.timeouts.implicit_wait = 10
        @driver.manage.window.maximize
        @wait = Selenium::WebDriver::Wait.new(:timeout => 2000)
        @driver
    end

    def login
        puts "connecting url is : #{@base_url}"
        begin
            @driver.get(@base_url)
        rescue => e
            puts "Site side issue, page not loaded properly, #{e.message}"
            @base_url = "https://www.socialtrade.biz"
            @driver.get(@base_url)
        end
        sleep 10
        popup
        begin
            @driver.find_element(:xpath, "//input[@placeholder='Enter Your User ID Here']").clear
            @driver.find_element(:xpath, "//input[@placeholder='Enter Your User ID Here']").send_keys @username
            @driver.find_element(:xpath, "//input[@placeholder='Enter Your Password']").clear
            @driver.find_element(:xpath, "//input[@placeholder='Enter Your Password']").send_keys @password 
            @driver.find_element(:xpath, "//input[@value='Sign In']").click
            puts "Login button clicked."
        rescue => e
            puts "login side issue, page not loaded properly."
        end
        sleep 5
        popup
    end

    def popup
        begin
            @driver.find_element(:xpath, "//img[@class='close-image']").click
            puts "popup closed"
            sleep 5
        rescue => e
            puts "There is no popup."
        end
    end

    def test_clicker
        @week_name = (Date.today).strftime("%A")
        if !is_date?($pending_date) || ($user.nil? || $password.nil? || $table_rows.nil? || $pending_date.nil?) and (!$pending_date.nil? || (@week_name.downcase == "saturday" || @week_name.downcase == "sunday"))
            if !$pending_date.nil? and !is_date?($pending_date)
                puts "Pending work date format is invalid. Please pass like this 'YYYY-MM-DD', ex: 2016-08-22"
            end
            puts "Today is #{@week_name}. Please provide username, password, links count number and pending work date."
        elsif $user.nil? || $password.nil? || $table_rows.nil?
            puts "Please provide username, password and links count number."
        else
            login
            popup
            begin
                @driver.find_element(:link_text, "View Advertisements").click
                puts "View Work button clicked."
                sleep 5
            rescue => e
                puts "View Work Button side issue: #{e.message}"
                begin
                    @driver.find_element(:link_text, "View Advertisements").click
                rescue => e
                    puts "View Work Side issue: #{e.message}"
                end
                sleep 5
            end
            @pending_date_work = true
            begin
                if !$pending_date.nil? and (@week_name.downcase == "saturday" || @week_name.downcase == "sunday")
                    puts "Pending work date is: #{$pending_date}"
                    @driver.find_element(:xpath, "//input[@placeholder='Select pending work date']").clear
                    @driver.find_element(:xpath, "//input[@placeholder='Select pending work date']").send_keys $pending_date
                    @driver.find_element(:xpath, "//button[@value='Request For Work']").click
                    @driver.find_element(:xpath, "//button[@value='Request For Work']").click
                    puts "Request For Work button clicked."
                    sleep 10
                    begin
                        @driver.find_element(:xpath, "/html/body/div[3]/div[7]/div/button").click
                        @pending_date_work = false
                    rescue => e
                    end
                end
            rescue
            end
            if @pending_date_work
                if work_checker?
                    count = links_clicker
                    puts "#{count} rows completed."
                else
                    puts "Some site side issue or Today work is not available."
                end
            else
                puts "Sorry no work available on this date, Thanks."
            end
        end
    end

    def links_clicker
        i = 1
        @count = 0
        begin
            if clicked?(i)
                puts "#{i} row already clicked."
                @count = @count+1
            else
                j = 1
                begin
                    if pending?(i)        
                        row_click(i)
                        if clicked?(i)
                            print "Status done."
                            puts ""
                            @count = @count+1
                            break
                        else
                            print "Status not done, process repeat again."
                            puts ""
                        end
                    else
                        if clicked?(i)
                            puts "#{i} row already clicked."
                            @count = @count+1
                            break
                        else
                            sleep 5
                        end
                    end
                    j= j+1
                    if j == 10
                        @driver.navigate.refresh
                        puts "Page refreshed."
                        j = 1
                    end
                end while j <= 10
            end
            i = i+1
        end while i <= $table_rows.to_i
        return @count
    end

    def work_checker?
        @social = "1"
        # begin
        #     if @driver.find_element(:xpath, "#{select_target('social', '1', 'Clicked')}").text == "Clicked"
        #         return true
        #     elsif @driver.find_element(:xpath, "#{select_target('social', '1', 'Pending')}").text == "Pending"
        #         return true
        #     else
        #         return false
        #     end
        # rescue => e
        #     @social = "0"
        #     puts "Resque Work checker side issue: #{e.message}"
        #     begin
        #         if @driver.find_element(:xpath, "#{select_target('sserp', '1', 'Clicked')}").text == "Clicked"
        #             return true
        #         elsif @driver.find_element(:xpath, "#{select_target('sserp', '1', 'Pending')}").text == "Pending"
        #             return true
        #         else
        #             return false
        #         end
        #     rescue => e
        #         puts "Resque1 Work checker side issue: #{e.message}"
        #         return false
        #     end
        # end
        return true
    end

    def clicked?(row)
        begin
            if @driver.find_element(:xpath, "#{select_target('social',row, 'Clicked')}").text == "Clicked"
                return true
            end
        rescue
            begin
                if @driver.find_element(:xpath, "#{select_target('sserp',row, 'Clicked')}").text == "Clicked"
                    return true
                end
            rescue Exception => e
                puts "Clicked checker side issue: #{e}"
            end
        end
        return false
    end

    def pending?(row)
        begin
            if @driver.find_element(:xpath, "#{select_target('social',row, 'Clicked')}").text == "Pending"
                return true
            end
        rescue
            begin
                if @driver.find_element(:xpath, "#{select_target('sserp',row, 'Clicked')}").text == "Pending"
                    return true
                end
            rescue Exception => e
                puts "Pending checker side issue: #{e}"
            end
        end
        return false
    end

    def row_click(row)
        begin
            @driver.find_element(:xpath, "#{select_target('social', row, 'Click')}").click
            print "Clicked #{row} row, "
            sleep rand(32..45)
        rescue
            begin
                @driver.find_element(:xpath, "#{select_target('sserp', row, 'Click')}").click
                print "Clicked #{row} row, "
                sleep rand(32..45)
            rescue
                print "Already #{row} row clicked,"
                sleep 10
            end
        end
    end

    def select_target(link_type, row, type)
        if @social == "1"
            link_type = "social"
        else
            link_type = "sserp"
        end
        if link_type == "social"
            if type == "Work"
                value = "/html/body/form/div[4]/div/div[2]/div/div/div/div/div/div[2]/b/a"
            elsif type == "Clicked"
                # value = "html/body/form/div[4]/div/div[3]/div/div/div/div[3]/div[1]/div[2]/div[2]/div/tr[#{row}]/td[3]/span/b"
                value = "html/body/form/div[4]/div/div[3]/div/div/div/div[4]/table[2]/tbody/tr[#{row}]/td[3]/span/b"
            elsif type == "Click"
                #value = "html/body/form/div[4]/div/div[3]/div/div/div/div[3]/div[1]/div[2]/div[2]/div/tr[#{row}]/td[4]/span[2]/i"
                value = "html/body/form/div[4]/div/div[3]/div/div/div/div[4]/table[2]/tbody/tr[#{row}]/td[4]/span[2]/i"
            elsif type == "Pending"
                #value = "html/body/form/div[4]/div/div[3]/div/div/div/div[3]/div[1]/div[2]/div[2]/div/tr[11]/td[3]/span/b"
                value = "html/body/form/div[4]/div/div[3]/div/div/div/div[4]/table[2]/tbody/tr[#{row}]/td[3]/span/b"
            end
        else
            if type == "Work"
                value = "/html/body/form/div[3]/div/div[2]/div/div/div/div/div/div[2]/b/a"
            elsif type == "Clicked"
                value = "html/body/form/div[3]/div/div[3]/div/div/div/div[3]/div[1]/div[2]/div[2]/div/tr[#{row}]/td[3]/span/b"
            elsif type == "Click"
                value = "html/body/form/div[3]/div/div[3]/div/div/div/div[3]/div[1]/div[2]/div[2]/div/tr[#{row}]/td[4]/span[2]/i"
            elsif type == "Pending"
                value = "html/body/form/div[3]/div/div[3]/div/div/div/div[3]/div[1]/div[2]/div[2]/div/tr[1]/td[3]/span/b"
            end
        end
        return value
    end

    def signout
        begin
            @driver.find_element(:xpath, "/html/body/form/header/div/div/div/nav/div/div[1]/ul/li/a/i").click
            sleep 5
            @driver.find_element(:xpath, "/html/body/form/header/div/div/div/nav/div/div[1]/ul/li/ul/li[7]/a/div/span[1]").click
            puts "Successfuly loged out."
        rescue => e
            puts "signout side issue."
        end
    end

    def is_date?(value)
        begin
            date_time = value.split(" ")
            if date_time.length == 2
                return false
            else
                date = value.split("-")
                
                if !date[1].nil?
                    if date[1].to_i == 1 || date[1].to_i == 3 || date[1].to_i == 5 || date[1].to_i == 7 || date[1].to_i == 8 || date[1].to_i == 10 || date[1].to_i == 12
                        days = 31
                    elsif date[1].to_i == 4 || date[1].to_i == 6 || date[1].to_i == 9 || date[1].to_i == 11
                        days = 30
                    elsif date[1].to_i == 2
                        if Date.leap?(date[0].to_i)
                            days = 29
                        else
                            days = 28
                        end
                    end
                end
                if date[0].length == 4 and date[1].to_i < 13 and date[2].to_i < days+1
                    return true
                else
                    return false
                end
            end
        rescue
            return false
        end
    end

    def verify_links
        i = 1
        count = 0
        begin
            begin
                if @driver.find_element(:xpath, "html/body/form/div[5]/div/div[4]/div/div/tr["+i.to_s+"]/td[3]/span/b").text == "Clicked"
                    count = count+1
                    puts "its verifying already clicked row #{i}"
                else
                    begin
                        if @driver.find_element(:xpath, "html/body/form/div[5]/div/div[4]/div/div/tr["+i.to_s+"]/td[3]/span/span/b").text == "clicked"
                            count = count+1
                            puts "just now clicked row: #{i}"
                        end
                    rescue => e
                    end
                end
                i = i+1
            rescue => e
            end
        end while i <= $table_rows.to_i
        return count
    end

    # Throws an assertion errors
    def teardown
        signout
        @driver.quit
        assert_equal [], @verification_errors
    end

end

