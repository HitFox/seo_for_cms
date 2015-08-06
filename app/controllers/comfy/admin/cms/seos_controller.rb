class Comfy::Admin::Cms::SeosController < Comfy::Admin::Cms::BaseController
  def index
  end

  def check
    webpage = 'https://www.github.com'
    @url_list, @bad_urls = Crawler.get_url_list_of(webpage)
    @result = Crawler.crawl_webpage(webpage)
  end
end
