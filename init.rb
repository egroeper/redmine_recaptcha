# Rails plugin initialization.

require 'recaptcha'
require 'net/http'
require 'recaptcha/rails'
require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare :redmine_recaptcha do
  require_dependency 'recaptcha/client_helper'
  require_dependency 'client_helper_patch'
  Recaptcha::ClientHelper.send(:include, ClientHelperPatch) 

  require_dependency 'account_controller'
  require_dependency 'account_controller_patch'
  AccountController.send(:include, AccountControllerPatch) 
end

Redmine::Plugin.register :redmine_recaptcha do
  name 'reCAPTCHA for user self registration'
  author 'Shane StClair'
  description 'Adds a recaptcha to the user self registration screen to combat spam'
  version '0.1.0'
  url 'http://github.com/srstclair/redmine_recaptcha'
  #requires_redmine :version_or_higher => '0.9.0'
  settings :default => {
     'recaptcha_private_key' => '',
     'recaptcha_public_key' => ''
  }, :partial => 'settings/redmine_recaptcha'

end

