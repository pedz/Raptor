#!/usr/bin/env ruby
require 'rubygems'
require 'curb'
require 'nokogiri'

URL='http://techsupport.rchland.ibm.com/catalog.nsf/DomainQuery'
USER='pedzan@us.ibm.com'
PASS='cat8golf'

http = Curl::Easy.new(URL)
http.enable_cookies = true
http.follow_location = true
http.cookiejar = "my-cookies"
http.http_get

# puts http.status
# puts http.redirect_url
# puts http.header_size
# puts http.header_str
# puts http.cookies
# puts http.body_str

doc = Nokogiri::HTML(http.body_str)
form = doc.css('form').find_all { |node| node['name'] == 'logonForm' }
# form = doc.css('name=logonForm')
puts form.length
puts form[0]
