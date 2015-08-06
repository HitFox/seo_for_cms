class Crawler

  def initialize(webpage)
    @keypage = webpage
    @all_header = []
    @all_links_per_page = []
    @p_class = []
    @p = []
    @canon_links = []
    @url_list = []
    @bad_urls = []
  end

  def crawl_webpage
    get_url_list_of(@keypage)
    fetcher_of(@keypage)
    return_all
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
    result[:url_list] = @url_list
    result[:bad_ulrs] = @bad_urls

    result
  end

  def fetcher_of(webpage)
    # Fetch and parse HTML document
    doc = Nokogiri::HTML(open(webpage))
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

  #@counter = 0
  def get_url_list_of(webpage)
    # fetch all URLs of the whole webpage
    #@counter += 1
    #puts webpage
    # if webpage.match(/mailto:/)
    #   webpage = 'https://www.valendo.de/mail_info_placeholder_for_debugging'
    # end
    
    # if webpage.match(/.css/)
    #   webpage = 'https://www.valendo.de/css_placeholder_for_debugging'
    # end

    # unless webpage.match(/http/)
    #   unless webpage.match(/^\//)
    #     webpage = '/'+webpage
    #   end
    #   webpage = 'https://www.valendo.de'+webpage
    # end

    #puts webpage
    begin
      doc = Nokogiri::HTML(open(webpage))
      doc.xpath('//@href').each do |url|
        unless @url_list.include? url.to_s
          @url_list << url.to_s
        end
      end
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        @bad_urls << 'not found 404 '+webpage
      elsif e.message == '400 Not Found'
        @bad_urls << 'not found 400 '+webpage
      else
        @bad_urls << 'unknown code '+webpage
      end
    end
    #puts @url_list.length
    #self.get_url_list_of((@url_list[@counter-1]).to_s)
  end
end
