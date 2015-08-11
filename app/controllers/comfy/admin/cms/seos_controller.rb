class Comfy::Admin::Cms::SeosController < Comfy::Admin::Cms::BaseController
  def index
  end

  def wait
    render 'wait'
  end

  def check
    webpage = 'https://www.savedo.de'
    crawler = Crawler.new(webpage)
    @result = crawler.crawl_webpage
  end
end



# Build a Page where you render "Some page telling user to wait" do a 
#   AJAX call to the controller action which imports the contacts from 
#   facebook and do the render in this action AFTER the import has finished and 
#     you should be fine! When the AJAX response is received replace the waiting message 
#     with the result from the server! –  alex Apr 7 '12 at 11:19
