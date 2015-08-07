class Crawler
  # crawles the given webpage and it's children and fetches their attributes.
  def initialize(webpage)
    @key_url = webpage
    @url_hash = {}
    @attributes_hash = {}
  end

  def crawl_webpage
    internationalize_key_url(@key_url.dup)
    search_url_hash(@key_url)
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
        # double check for valid, so no error if in rescue case
        if get_url_list_of(url)
          fetcher_of(url)
        end
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
        return false
      end
    end
    return true
  end

  def valid_url?(url)
    case url
    when /http:\/\//
      @url_hash[url] = 'invalid'
      return false
    when /mailto:/
      @url_hash[url] = 'system'
      return false
    when /.css/
      @url_hash[url] = 'system'
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
    @system_urls_array =[]
    @error_urls_array =[]
    @url_hash.each do |url, validator|
      case validator
      when 'valid'
        @valid_urls_array << url 
      when 'invalid'
        @invalid_urls_array << url
      when 'system'
        @system_urls_array << url
      else
        @error_urls_array << url
      end
    end
  end

  def fetcher_of(page_url)
    all_h1_header = []
    title = []
    meta_description = []
    all_links = []
    p_class_tag = []
    p_tag = []
    canon_links = []
    result_hash = {}
    # Fetch and parse HTML document
    doc = Nokogiri::HTML(open(page_url))
    @doc = doc

    doc.xpath('//h1[@class]').each do |header|
      all_h1_header << header.text
    end

    doc.xpath('//title').each do |t|
      title = t.text
    end

    doc.xpath('//meta[@name="description"]').each do |description|
      meta_description = description.to_s
    end

    doc.xpath('//a[@href]').each do |link|
      all_links << link
    end

    doc.xpath('//p[@class]').each do |p_class|
      p_class_tag << p_class.text
    end
    check_length(p_class_tag)

    doc.xpath('//p').each do |p|
      p_tag << p.text
    end
    check_length(p_tag)

    doc.xpath('//link[@rel="canonical"]').each do |canon_links|
      @canon_links = canon_links
    end

    result_hash[:all_h1_header] = all_h1_header
    result_hash[:title] = title
    result_hash[:meta_description] = meta_description
    result_hash[:num_of_links] = all_links.count
    result_hash[:p_class_tag] = p_class_tag
    result_hash[:p_tag] = p_tag
    result_hash[:canonical_links] = canon_links
    @attributes_hash[page_url] = result_hash
  end

  def check_length(attri)
    temp = attri.dup
    text_to_long = false
    temp.each do |text|
      if text.split(' ').size > 150
        attri << 'yes: ' + text
        text_to_long = true
      end
    end
    attri << 'no' unless text_to_long
  end

  def return_all
    result = {}
    result[:attributes_hash] = @attributes_hash
    result[:valid_urls_array] = @valid_urls_array
    result[:system_urls_array] = @system_urls_array
    result[:invalid_urls_array] = @invalid_urls_array
    result[:error_urls_array] = @error_urls_array

    result
  end
end
