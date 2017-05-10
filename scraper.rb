#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.xpath('//h3[.//span[@id="Members"]]/following-sibling::table[1]//tr[td]').each do |tr|
    tds = tr.css('td')
    data = {
      name:           tds[1].text.tidy,
      wikiname:       tds[1].xpath('.//a[not(@class="new")]/@title').text,
      area:           tds[0].text.tidy,
      party:          tds[2].text.tidy,
      party_wikiname: tds[2].xpath('.//a[not(@class="new")]/@title').text,
    }
    ScraperWiki.save_sqlite(%i(name area party), data)
  end
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
scrape_list('https://en.wikipedia.org/wiki/29th_House_of_Representatives_of_Puerto_Rico')
