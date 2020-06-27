#!/usr/bin/env ruby

require 'capybara'
require 'nokogiri'
require 'selenium/webdriver'
require 'colorize'
require 'shellwords'
require 'net/http'
require 'fileutils'
require 'uri'
require 'progressbar'


def time_str()
  return (Time.now.strftime "%F_%T").gsub(":", "-")
end

def get_text_node_contents_only(element)
    return element.evaluate_script(
      %Q{
      (function(p){
        var child = p.firstChild;
        var textValue = "";
        while(child) {
            if (child.nodeType === Node.TEXT_NODE) {
                textValue += child.textContent;
            }
            child = child.nextSibling;
        }
        return textValue;
      })(arguments[0])}, element).strip()
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  o = %w[ headless
          disable-gpu
          mute-audio
          disable-extensions
          disable-password-generation
          disable-password-manager-reauthentication
          disable-save-password-bubble ]

  o.each { |o| options.add_argument o }

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.run_server = false
Capybara.default_driver = :headless_chrome
Capybara.javascript_driver = :headless_chrome
Capybara.ignore_hidden_elements = false

$stderr.sync = $stdout.sync = true
Signal.trap('PIPE', 'EXIT')

#USER_AGENT = ENV.fetch('USER_AGENT', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/76.0.3809.87 Safari/537.36')

session = Capybara::Session.new(Capybara.default_driver)

URL = ARGV.shift
session.visit(URL)

items = session.all(:xpath, "//div[@class='collectionChildren']//div[@class='workshopItem']/a").map {|a| a[:href]}

session.visit("http://steamworkshop.download/")
form = session.find(:xpath, "//form[@id='workshop']")
text = form.find(:xpath, "./input[@type='text']")
butt = form.find(:xpath, "./input[@type='submit']")

items.each do |item|
  text.set(item)
  butt.click
  sleep(1)
  #session.save_screenshot("screenshot_#{time_str}.png")
  link = session.find(:xpath, "//td[@class='tbl1']/b/a")
  url = URI(link[:href])
  title = link[:title]
  filename = get_text_node_contents_only(link.find(:xpath, "..")).strip[/(?<=Filename: ).*$/]

  counter = 0
  Net::HTTP.start(url.host) do |http|
    response = http.request_head(url.path)
    total = response['Content-Length'].to_i
    puts [url, title, filename, total].join"\t"
    File.open(filename, 'w') do |f|
      http.get(url.path) do |str|
        f.write str
      end
    end
  end
end
