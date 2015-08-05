class Crawler
  def self.check_length(var)
    temp = var.dup
    temp.each do |text|
      puts 0
      if text.split(' ').size > 150
        var << 'yes' + text
        break
      else
        var << 'no'
      end
    end
  end

  def self.return_all
    result = {}
    result[:doc] = @doc
    result[:all_header] = @all_header
    result[:all_links] = @all_links.count
    result[:p_class] = @p_class.last
    result[:p] = @p.last
    result[:canon_links] = @canon_links
    result[:meta_description] = @meta_description
    result[:title] = @title.text

    result
  end

  def self.crawl_webpage(webpage)
    # Fetch and parse HTML document
    doc = Nokogiri::HTML(open(webpage))
    @doc = doc

    @all_header = []
    @all_links = []
    @p_class = []
    @p = []
    @canon_links = []

    doc.xpath('//h1[@class]').each do |header|
      @all_header << header.text
    end

    doc.xpath('//a[@class]').each do |link|
      @all_links << link
    end

    doc.xpath('//meta[@name="description"]').each do |description|
      @meta_description = description
    end

    doc.xpath('//title').each do |title|
      @title = title
    end

    doc.xpath('//p[@class]').each do |p_class|
      @p_class << p_class.text
    end
    check_length(@p_class)

    doc.xpath('//p').each do |p|
      @p << p.text
    end
    check_length(@p)

    doc.xpath('//link[@rel="canonical"]').each do |canon_links|
      @canon_links = canon_links
    end

    return_all
  end
end
