class Comfy::Admin::Cms::SeosController < Comfy::Admin::Cms::BaseController
  def index
  end

  def wait
    render 'wait'
  end

  def check
    webpage = 'http://www.ita-online.info'
    crawler = Crawler.new(webpage)
    start = Time.now
    @result = crawler.crawl_webpage
    after= Time.now
    puts start.to_s+' till '+after.to_s
  end
end
