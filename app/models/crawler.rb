class Crawler
  # crawles the given webpage and it's children and fetches their attributes.
  def initialize(webpage)
    @key_url = webpage
    @notes_hash = {}
    @url_hash = {}
    @attributes_hash = {}
    @valid_urls_array =[]
    @untested_urls_array =[]
    @system_urls_array =[]
    @error_urls_hash = {}
    @doc = ''
  end

  def crawl_webpage
    edit_key_url(@key_url.dup)
    search_url_hash(@key_url)
    return_all
  end

  def edit_key_url(key_url)
    # creates domain. and www.domain.
    key_url.match(/(https?:\/\/)(www\.|)(\b\S+)[\.]/)
    @www_key_url = $1+'www.'+$3+'.'
    @non_www_key_url = $1+$3+'.'
  end

  def search_url_hash(key_url)
    count = 0
    url_array = []
    @url_hash[key_url] = ['valid', key_url]
    url_array << key_url
    url_array.each do |url|
      count +=1
      if @url_hash[url].first == 'valid'
        if count > 300
          @notes_hash['too many links on all webpage?'] = 'yes, more than 300, please check!'
        end
        if get_url_list_of(url)
        # double check for valid, so no error if in rescue case
          fetcher_of(url)
          @url_hash.keys.each do |key|
            url_array << key
          end
          url_array.uniq!
        end
      end
    end
    divide_url_hash
  end

  def get_url_list_of(page_url)
    if Rails.env.development?
      puts page_url
    end
    begin
      @doc = Nokogiri::HTML(open(page_url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, allow_redirections: :all))
      @doc.xpath('//comment()').remove
      @doc.xpath('//@href').each do |url|
        attribute_to_url(url.to_s, page_url)
      end
    rescue OpenURI::HTTPError => e
      if e.message
        puts 'found u here? '+page_url
        @url_hash[page_url] = e.message
        return false
      end
    end
    return true
  end

  def attribute_to_url(url, parent_url)
    if !url.ascii_only?
      @url_hash[url] = ['untested', parent_url]
    else
      case url
      when /mailto:/
        @url_hash[url] = ['system', parent_url]
      when /\s/
        @url_hash[url] = ['untested', parent_url]
      when /\.pdf$/
        @url_hash[url] = ['system', parent_url]
      when /\.svg$/
        @url_hash[url] = ['system', parent_url]
      when /\.ico$/
        @url_hash[url] = ['system', parent_url]
      when /\.png$/
        @url_hash[url] = ['system', parent_url]
      when /\.css$/
        @url_hash[url] = ['system', parent_url]
      when /\.jpg$/
        @url_hash[url] = ['system', parent_url]
      when /^#/
        @url_hash[url] = ['untested', parent_url]
      when /^(?!http)/
        add_domain_to_url(url, parent_url)
      when /^#{@www_key_url}/
        @url_hash[url] = ['valid', parent_url]
      when /^#{@non_www_key_url}/
        @url_hash[url] = ['valid', parent_url]
      else
        @url_hash[url] = ['untested', parent_url]
      end
    end
  end

  def add_domain_to_url(url, parent_url)
    unless url.match(/^\//)
      url = '/'+url
    end
    url = @key_url+url
    attribute_to_url(url, parent_url)
  end

  def divide_url_hash
    @url_hash.each do |url, validator|
      puts '???????????????????'
      puts url
      puts validator
      puts '???????????????????'
      if url != @key_url
        case validator.first
        when 'valid'
          @valid_urls_array << [url, validator.last] 
        when 'untested'
          @untested_urls_array << [url, validator.last]
        when 'system'
          @system_urls_array << [url, validator.last]
        else
          puts 'found u '+url
          @error_urls_hash[url] = validator
        end
      end
    end
  end

  def fetcher_of(page_url)
    # Fetch and parse HTML document
    all_h1_header = []
    all_h2_header = []
    all_h3_header = []
    all_h4_header = []
    all_h5_header = []
    all_h6_header = []
    title = []
    meta_description = []
    all_links = []
    p_tag = []
    canon_links = []
    img_tags = []
    result_hash = {}

    @doc.xpath('//h1').each do |header|
      all_h1_header << header.text
    end
    @doc.xpath('//h2').each do |header|
      all_h2_header << header.text
    end
    @doc.xpath('//h3').each do |header|
      all_h3_header << header.text
    end
    @doc.xpath('//h4').each do |header|
      all_h4_header << header.text
    end
    @doc.xpath('//h5').each do |header|
      all_h5_header << header.text
    end
    @doc.xpath('//h6').each do |header|
      all_h6_header << header.text
    end

    @doc.xpath('//title').each do |t|
      title << t.text
    end

    @doc.xpath('//meta[@name="description"]').each do |description|
      meta_description << description.to_s
    end

    @doc.xpath('//a[@href]').each do |link|
      all_links << link
    end

    @doc.xpath('//p').each do |p|
      p_tag << p.text
    end
    check_length(p_tag)

    @doc.xpath('//link[@rel="canonical"]').each do |can_links|
      canon_links << can_links
    end

    @doc.xpath('//img').each do |pic|
      img_tags << pic.to_s
    end

    result_hash[:all_h1_header] = all_h1_header
    result_hash[:all_h2_header] = all_h2_header
    result_hash[:all_h3_header] = all_h3_header
    result_hash[:all_h4_header] = all_h4_header
    result_hash[:all_h5_header] = all_h5_header
    result_hash[:all_h6_header] = all_h6_header
    result_hash[:title] = title
    result_hash[:meta_description] = meta_description
    result_hash[:num_of_links] = all_links.count
    result_hash[:p_tag_to_long] = p_tag.last
    result_hash[:canonical_links] = canon_links
    result_hash[:image_and_alt] = check_alt_tag(img_tags)

    @attributes_hash[page_url] = result_hash
  end

  def check_length(attri)
    temp = attri.dup
    text_to_long = false
    temp.each do |text|
      if text.encoding == 'UTF-8'
        if text.split(' ').size > 150
          attri << 'yes: ' + text
          text_to_long = true
        end
      # do i need a warning here?
      end
    end
    attri << 'no' unless text_to_long
  end

  def check_alt_tag(images)
    image_tag_hash = {}
    images.each do |img|
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
    result[:error_urls_hash] = @error_urls_hash
    result[:system_notes] = @notes_hash
    result
  end
end
