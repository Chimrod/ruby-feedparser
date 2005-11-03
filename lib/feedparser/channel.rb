# This class allows to retrieve a feed and parse it into a Channel

require 'rexml/document'
require 'time'
require 'feedparser/textconverters'
require 'feedparser/rexml_patch'
require 'base64'

class UnknownFeedTypeException < RuntimeError
end
# an RSS/Atom channel
class Channel
  attr_reader :title, :link, :description, :creator, :encoding, :items

  # parse str to build a channel
  def initialize(str = nil)
    parse_str(str) if str
  end

  # Determines all the fields using a string containing an
  # XML document
  def parse_str(str)
    # Dirty hack: some feeds contain the & char. It must be changed to &amp;
    str.gsub!(/&(\s+)/, '&amp;\1')
    doc = REXML::Document.new(str)
    # get channel info
    @encoding = doc.encoding
    @title,@link,@description,@creator = nil
    @items = []
    if doc.root.elements['channel'] || doc.root.elements['rss:channel']
      # We have a RSS feed!
      # Title
      if (e = doc.root.elements['channel/title'] ||
        doc.root.elements['rss:channel/rss:title']) && e.text
        @title = e.text.toUTF8(@encoding).rmWhiteSpace!
      end
      # Link
      if (e = doc.root.elements['channel/link'] ||
          doc.root.elements['rss:channel/rss:link']) && e.text
        @link = e.text.rmWhiteSpace!
      end
      # Description
      if (e = doc.root.elements['channel/description'] || 
          doc.root.elements['rss:channel/rss:description']) && e.text
        @description = e.text.toUTF8(@encoding).rmWhiteSpace!
      end
      # Creator
      if ((e = doc.root.elements['channel/dc:creator']) && e.text) ||
          ((e = doc.root.elements['channel/author'] ||
          doc.root.elements['rss:channel/rss:author']) && e.text)
        @creator = e.text.toUTF8(@encoding).rmWhiteSpace!
      end
      # Items
      if doc.root.elements['channel/item']
        query = 'channel/item'
      elsif doc.root.elements['item']
        query = 'item'
      elsif doc.root.elements['rss:channel/rss:item']
        query = 'rss:channel/rss:item'
      else
        query = 'rss:item'
      end
      doc.root.each_element(query) { |e| @items << Item::new(e, self) }

    elsif doc.root.elements['/feed']
      # We have an ATOM feed!
      # Title
      if (e = doc.root.elements['/feed/title']) && e.text
        @title = e.text.toUTF8(@encoding).rmWhiteSpace!
      end
      # Link
      doc.root.each_element('/feed/link') do |e|
        if e.attribute('type') and (
            e.attribute('type').value == 'text/html' or
            e.attribute('type').value == 'application/xhtml' or
            e.attribute('type').value == 'application/xhtml+xml')
          if (h = e.attribute('href')) && h
            @link = h.value.rmWhiteSpace!
          end
        end
      end
      # Description
      if e = doc.root.elements['/feed/info']
        @description = e.elements.to_s.toUTF8(@encoding).rmWhiteSpace!
      end
      # Items
      doc.root.each_element('/feed/entry') do |e|
         @items << AtomItem::new(e, self)
      end
    else
      raise UnknownFeedTypeException::new
    end
  end

  def to_s
    s = "Title: #{@title}\nLink: #{@link}\n\n"
    @items.each { |i| s += i.to_s }
    s
  end
end

# an Item from a channel
class Item
  attr_accessor :title, :link, :content, :date, :creator, :subject,
                :category, :cacheditem
  attr_reader :channel
  def initialize(item = nil, channel = nil)
    @channel = channel
    @title, @link, @content, @date, @creator, @subject, @category = nil
    if item
      # Title
      if ((e = item.elements['title'] || item.elements['rss:title']) &&
          e.text)  ||
          ((e = item.elements['pubDate'] || item.elements['rss:pubDate']) &&
           e.text)
        @title = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
      # Link
      if ((e = item.elements['link'] || item.elements['rss:link']) && e.text)||
          (e = item.elements['guid'] || item.elements['rss:guid'] and
          not (e.attribute('isPermaLink') and
          e.attribute('isPermaLink').value == 'false'))
        @link = e.text.rmWhiteSpace!
      end
      # Content
      if (e = item.elements['content:encoded']) ||
        (e = item.elements['description'] || item.elements['rss:description'])
        if e.children.length > 1
          s = ''
          e.children.each { |c| s += c.to_s }
          @content = s.toUTF8(@channel.encoding).rmWhiteSpace!.text2html
        elsif e.children.length == 1
          if e.cdatas[0]
            @content = e.cdatas[0].to_s.toUTF8(@channel.encoding).rmWhiteSpace!
          elsif e.text
            @content = e.text.toUTF8(@channel.encoding).text2html
          end
        end
      end
      # Date
      if e = item.elements['dc:date'] || item.elements['pubDate'] || 
          item.elements['rss:pubDate']
        begin
          @date = Time::xmlschema(e.text)
        rescue
          begin
            @date = Time::rfc2822(e.text)
          rescue
            begin
              @date = Time::parse(e.text)
            rescue
              @date = nil
            end
          end
        end
      end
      # Creator
      @creator = @channel.creator
      if (e = item.elements['dc:creator'] || item.elements['author'] ||
          item.elements['rss:author']) && e.text
        @creator = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
      # Subject
      if (e = item.elements['dc:subject']) && e.text
        @subject = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
      # Category
      if (e = item.elements['dc:category'] || item.elements['category'] ||
          item.elements['rss:category']) && e.text
        @category = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
    end
  end

  def to_s
    "--------------------------------\n" +
      "Title: #{@title}\nLink: #{@link}\n" +
      "Date: #{@date.to_s}\nCreator: #{@creator}\n" +
      "Subject: #{@subject}\nCategory: #{@category}\nContent:\n#{content}\n"
  end

  def to_text
    s = ""
    s += "Channel: "
    s += @channel.title.toISO_8859_1('utf-8') + ' ' if @channel.title
    s += "<#{@channel.link.toISO_8859_1('utf-8')}>" if @channel.link
    s += "\n"
    s += "Item: "
    s += @title.toISO_8859_1('utf-8') + ' ' if @title
    s += "<#{@link.toISO_8859_1('utf-8')}>" if @link
    s += "\n"
    s += "\nDate: #{@date.to_s.toISO_8859_1('utf-8')}" if @date # TODO improve date rendering ?
    s += "\nAuthor: #{@creator.toISO_8859_1('utf-8')}" if @creator

    s += "\nSubject: #{@subject.toISO_8859_1('utf-8')}" if @subject
    s += "\nCategory: #{@category.toISO_8859_1('utf-8')}" if @category
    s += "\n\n"
    s += "#{@content.html2text.toISO_8859_1('utf-8')}" if @content
    s
  end

  def to_html
    s = '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">'
    s += '<html>'
    s += '<body>'
    s += "<p>Channel: "
    s += "<a href=\"#{@channel.link}\">" if @channel.link
    s += @channel.title if @channel.title
    s += "</a>" if @channel.link
    s += "<br/>\nItem: "
    s += "<a href=\"#{@link}\">" if @link
    s += @title if @title
    s += "</a>" if @link
    s += "\n"
    s += "<br/>Date: #{@date.to_s}" if @date # TODO improve date rendering ?
    s += "<br/>Author: #{@creator}" if @creator
    s += "<br/>Subject: #{@subject}" if @subject
    s += "<br/>Category: #{@category}" if @category
    s += "</p>"
    s += "<p>#{@content}</p>" if @content
    s += '</body></html>'
    s
  end
end

class AtomItem < Item
  def initialize(item = nil, channel = nil)
    @channel = channel
    @title, @link, @content, @date, @creator, @subject, @category = nil
    if item
      # Title
      if (e = item.elements['title']) && e.text
        @title = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
      # Link
      item.each_element('link') do |e|
        if e.attribute('type').value == 'text/html' or
          e.attribute('type').value == 'application/xhtml' or
          e.attribute('type').value == 'application/xhtml+xml'
          if (h = e.attribute('href')) && h.value
            @link = h.value
          end
        end
      end
      # Content
      if e = item.elements['content'] || item.elements['summary']
        if (e.attribute('mode') and e.attribute('mode').value == 'escaped') &&
          e.text
          @content = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
        else
          # go one step deeper in the recursion if possible
          e = e.elements['div'] || e
          @content = e.to_s.toUTF8(@channel.encoding).rmWhiteSpace!
        end
      end
      # Date
      if (e = item.elements['issued'] || e = item.elements['created']) && e.text
        begin
          @date = Time::xmlschema(e.text)
        rescue
          begin
            @date = Time::rfc2822(e.text)
          rescue
            begin
              @date = Time::parse(e.text)
            rescue
              @date = nil
            end
          end
        end
      end
      # Creator
      @creator = @channel.creator
      if (e = item.elements['author/name']) && e.text
        @creator = e.text.toUTF8(@channel.encoding).rmWhiteSpace!
      end
    end
  end
end
