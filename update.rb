#!/usr/bin/env ruby
require 'maildir'
require 'mail'
require 'rss'
require 'open-uri'
require 'opml-parser'
include OpmlParser

$domain = '@feedreader'

STDOUT.sync = true

def send_item target, feed_title, item_title, link, description, date
  maildir = Maildir.new("data/mail/#{target}/Maildir")
  mail = Mail.new do
    from feed_title
    to target + $domain
    subject item_title
    content_type 'text/html; charset=UTF-8'
    body "<a href=\"#{link}\">#{link}</a><hr/>" + description
    date date
  end
  maildir.add mail.to_s
end

def handle_feed target, url
  puts "#{target} #{url}"
  URI.open(url) do |rss|
    feed = RSS::Parser.parse rss, :validate => false
    case feed.feed_type
    when 'rss'
      feed.items.each do |item|
        send_item target, feed.channel.title, item.title, item.link, item.description, item.pubDate
      end
    when 'atom'
      feed.items.each do |item|
        send_item target, feed.title.content, item.title.content, item.link.href, item.summary.content, item.updated.content
      end
    else
      puts "unsupported feed type #{feed.feed_type}"
      exit
    end
  end
end

Dir['data/mail/*/'].map do |base|
  user = base.split('/')[-1]
  OpmlParser.import(File.read(base + 'opml.xml')).each do |outline|
    url = outline.attributes[:xmlUrl]
    next unless url
    begin
      handle_feed user, url
    rescue Exception => e # i shouldn't but :shrug:
      p e
    end
  end
end
