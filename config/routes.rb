Rails.application.routes.draw do
  comfy_route :cms_admin, :path => '/admin'
  get 'comfy/admin/cms/seos/index'
  get 'comfy/admin/cms/seos/check'

  # Make sure this routeset is defined last
  comfy_route :cms, :path => '/', :sitemap => false
end
