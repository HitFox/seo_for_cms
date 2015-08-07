class Crawler
  # crawles the given webpage and it's children and fetches their attributes.
  def initialize(webpage)
    @key_url = webpage
    @url_hash = {}
    @attributes_hash = {}
  end

  def crawl_webpage
    edit_key_url(@key_url.dup)
    search_url_hash(@key_url)
    return_all
  end

  def edit_key_url(key_url)
    # test for https://domain. and https://www.domain.
    key_name = key_url.match(/www\.(\b\w+)[\.]/)[1]
    @www_key_url = 'https://www.'+key_name.to_s
    @non_www_key_url = 'https://'+key_name.to_s
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
        @url_hash[page_url] = e.message
        return false
      end
    end
    return true
  end

  def valid_url?(url)
    case url
    when /http:\/\//
      @url_hash[url] = 'untested'
      return false
    when /mailto:/
      @url_hash[url] = 'system'
      return false
    when /.css/
      @url_hash[url] = 'system'
      return false
    when /^#/
      @url_hash[url] = 'untested'
      return false
    when /^\//
      check_url(url)
    when /\/$/
      @url_hash[url] = 'untested'
      return false
    when /#{@www_key_url}/
      @url_hash[url] = 'valid'
      return true
    when /#{@non_www_key_url}/
      @url_hash[url] = 'valid'
      return true
    else
      @url_hash[url] = 'untested'
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
    @untested_urls_array =[]
    @system_urls_array =[]
    @error_urls_array =[]
    @url_hash.each do |url, validator|
      case validator
      when 'valid'
        @valid_urls_array << url 
      when 'untested'
        @untested_urls_array << url
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
    p_tag = []
    canon_links = []
    img_tags = []
    result_hash = {}
    # Fetch and parse HTML document
    doc = Nokogiri::HTML(open(page_url))
    @doc = doc

    doc.xpath('//h1[@class]').each do |header|
      all_h1_header << header.text
    end

    doc.xpath('//title').each do |t|
      title << t.text
    end

    doc.xpath('//meta[@name="description"]').each do |description|
      meta_description << description.to_s
    end

    doc.xpath('//a[@href]').each do |link|
      all_links << link
    end

    doc.xpath('//p').each do |p|
      p_tag << p.text
    end
    check_length(p_tag)

    doc.xpath('//link[@rel="canonical"]').each do |can_links|
      canon_links << can_links
    end

    doc.xpath('//img').each do |pic|
      img_tags << pic.to_s
    end

    result_hash[:all_h1_header] = all_h1_header
    result_hash[:title] = title
    result_hash[:meta_description] = meta_description
    result_hash[:num_of_links] = all_links.count
    result_hash[:p_tag_to_long] = p_tag.last
    result_hash[:canonical_links] = canon_links
    result_hash[:image_with_alt] = check_alt_tag(img_tags)

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

  def check_alt_tag(imgages)
    image_tag_hash = {}
    imgages.each do |img|
      # put src and alt of imgage in a hash
      src = img.match(/src=.?("\S+)/) || 'no_src_found'
      alt = img.match(/alt=\W+((\w|\s)+)/) || 'no_alt_found'
      image_tag_hash[src] = alt
    end
    image_tag_hash
  end

  def return_all
    result = {}
    result[:attributes_hash] = @attributes_hash
    result[:valid_urls_array] = @valid_urls_array
    result[:system_urls_array] = @system_urls_array
    result[:untested_urls_array] = @untested_urls_array
    result[:error_urls_array] = @error_urls_array

    result
  end
end
