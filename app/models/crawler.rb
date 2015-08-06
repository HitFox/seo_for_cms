class Crawler
  # crawles the given webpage and it's children and fetches their attributes.
  def initialize(webpage)
    @key_url = webpage
    @all_header = []
    @all_links_per_page = []
    @p_class = []
    @p = []
    @canon_links = []
    @url_hash = {}
  end

  def crawl_webpage
    internationalize_key_url(@key_url.dup)
    search_url_hash(@key_url)
    fetcher_of(@key_url)
    return_all
  end

  def internationalize_key_url(key_url)
    @internationalized_key_url = key_url.gsub(/\b\w+$/, '')
  end

  def search_url_hash(key_url)
    @url_hash[key_url] = 'valid'
    url_array = []
    url_array << key_url
    url_array.each do |url|
      if @url_hash[url] == 'valid'
        get_url_list_of(url)
      end
      @url_hash.keys.each do |key|
        url_array << key
      end
      url_array.uniq!
    end
    divide_url_hash
  end

  def get_url_list_of(page_url)
      puts page_url
    begin
      doc = Nokogiri::HTML(open(page_url))
      doc.xpath('//@href').each do |url|
        valid_url?(url.to_s)
      end
    rescue OpenURI::HTTPError => e
      if e.message
        @url_hash[page_url] = 'invalid '+e.message
      end
    end
  end

  def valid_url?(url)
    case url
    when /http:\/\//
      @url_hash[url] = 'invalid'
      return false
    when /mailto:/
      @url_hash[url] = 'invalid'
      return false
    when /.css/
      @url_hash[url] = 'invalid'
      return false
    when /^#/
      @url_hash[url] = 'invalid'
      return false
    when /^\//
      check_url(url)
    when /\/$/
      @url_hash[url] = 'invalid'
      return false
    when /#{@internationalized_key_url}/
      @url_hash[url] = 'valid'
      return true
    else
      @url_hash[url] = 'invalid'
      return false 
    end
  end

  def check_url(url)
    unless url.match(/http/)
      unless url.match(/^\//)
        url = '/'+url
      end
      url = @key_url+url
    end
    valid_url?(url)
  end

  def divide_url_hash
    @valid_urls_array =[]
    @invalid_urls_array =[]
    @invalid_error_urls_array =[]
    @url_hash.each do |url, validator|
      case validator
      when 'valid'
        @valid_urls_array << url 
      when 'invalid'
        @invalid_urls_array << url
      else
        @invalid_error_urls_array << url
      end
    end
  end

  def fetcher_of(page_url)
    # Fetch and parse HTML document
    doc = Nokogiri::HTML(open(page_url))
    @doc = doc

    doc.xpath('//h1[@class]').each do |header|
      @all_header << header.text
    end

    doc.xpath('//a[@class]').each do |link|
      @all_links_per_page << link
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
  end

  def check_length(var)
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

  def return_all
    result = {}
    result[:doc] = @doc
    result[:all_header] = @all_header
    result[:all_links] = @all_links_per_page.count
    result[:p_class] = @p_class.last
    result[:p] = @p.last
    result[:canon_links] = @canon_links
    result[:meta_description] = @meta_description
    result[:title] = @title.text
    result[:valid_urls_array] = @valid_urls_array
    result[:invalid_urls_array] = @invalid_urls_array
    result[:invalid_error_urls_array] = @invalid_error_urls_array

    result
  end
end
