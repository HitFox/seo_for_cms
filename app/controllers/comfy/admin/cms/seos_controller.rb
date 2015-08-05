class Comfy::Admin::Cms::SeosController < Comfy::Admin::Cms::BaseController
  def index
  end

  def check
    @result = Crawler.crawl_webpage('https://www.github.com')
  end
end
